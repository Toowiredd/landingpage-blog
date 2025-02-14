/*
  # Comprehensive Database Migration and Validation

  1. Changes
    - Validates and enhances existing table structures
    - Adds missing columns and constraints
    - Optimizes data types and indexes
    - Implements audit logging
    - Adds data validation triggers
    
  2. Security
    - Maintains RLS policies
    - Enhances access controls
    - Adds audit logging
    
  3. Performance
    - Optimizes indexes
    - Adds proper constraints
    - Implements efficient triggers
*/

-- Create audit log table
CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  record_id uuid NOT NULL,
  operation text NOT NULL,
  old_data jsonb,
  new_data jsonb,
  changed_by uuid REFERENCES auth.users(id),
  changed_at timestamptz DEFAULT now()
);

-- Enable RLS on audit logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can view audit logs
CREATE POLICY "Admins can view audit logs"
  ON audit_logs
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs (table_name, record_id, operation, new_data, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, to_jsonb(NEW), auth.uid());
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, to_jsonb(OLD), to_jsonb(NEW), auth.uid());
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, changed_by)
    VALUES (TG_TABLE_NAME, OLD.id, TG_OP, to_jsonb(OLD), auth.uid());
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add audit triggers to tables
DROP TRIGGER IF EXISTS audit_posts_trigger ON posts;
CREATE TRIGGER audit_posts_trigger
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS audit_profiles_trigger ON profiles;
CREATE TRIGGER audit_profiles_trigger
  AFTER INSERT OR UPDATE OR DELETE ON profiles
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- Enhance posts table
ALTER TABLE posts
  ALTER COLUMN title SET NOT NULL,
  ALTER COLUMN slug SET NOT NULL,
  ALTER COLUMN content SET NOT NULL,
  ALTER COLUMN excerpt SET NOT NULL,
  ALTER COLUMN category_id SET NOT NULL,
  ALTER COLUMN author_id SET NOT NULL,
  ALTER COLUMN reading_time SET DEFAULT 5,
  ALTER COLUMN status SET DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS meta_description text,
  ADD COLUMN IF NOT EXISTS meta_keywords text[],
  ADD COLUMN IF NOT EXISTS featured boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS view_count integer DEFAULT 0;

-- Add post validation trigger
CREATE OR REPLACE FUNCTION validate_post()
RETURNS TRIGGER AS $$
BEGIN
  -- Ensure slug format
  NEW.slug := LOWER(REGEXP_REPLACE(NEW.slug, '[^a-z0-9]+', '-', 'g'));
  
  -- Trim whitespace
  NEW.title := TRIM(NEW.title);
  NEW.content := TRIM(NEW.content);
  NEW.excerpt := TRIM(NEW.excerpt);
  
  -- Set reading time if not provided
  IF NEW.reading_time IS NULL OR NEW.reading_time < 1 THEN
    NEW.reading_time := GREATEST(1, CEIL(LENGTH(NEW.content)::float / 1500));
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS posts_validation_trigger ON posts;
CREATE TRIGGER posts_validation_trigger
  BEFORE INSERT OR UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION validate_post();

-- Add missing indexes
CREATE INDEX IF NOT EXISTS posts_featured_published_idx ON posts(featured, status) WHERE status = 'published';
CREATE INDEX IF NOT EXISTS posts_view_count_idx ON posts(view_count DESC);
CREATE INDEX IF NOT EXISTS posts_meta_keywords_idx ON posts USING gin(meta_keywords);

-- Add function to increment view count
CREATE OR REPLACE FUNCTION increment_view_count(post_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE posts
  SET view_count = view_count + 1
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comments validation
ALTER TABLE comments
  ALTER COLUMN content SET NOT NULL,
  ADD CONSTRAINT comments_content_length CHECK (LENGTH(TRIM(content)) >= 3);

-- Create function to get post stats
CREATE OR REPLACE FUNCTION get_post_stats(post_id uuid)
RETURNS TABLE (
  comment_count bigint,
  view_count integer,
  reading_time integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM comments WHERE comments.post_id = $1),
    p.view_count,
    p.reading_time
  FROM posts p
  WHERE p.id = $1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add function to search posts
CREATE OR REPLACE FUNCTION search_posts(search_query text)
RETURNS TABLE (
  id uuid,
  title text,
  excerpt text,
  slug text,
  status text,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.title,
    p.excerpt,
    p.slug,
    p.status,
    p.created_at
  FROM posts p
  WHERE 
    p.status = 'published'
    AND (
      p.title ILIKE '%' || search_query || '%'
      OR p.content ILIKE '%' || search_query || '%'
      OR p.excerpt ILIKE '%' || search_query || '%'
      OR search_query = ANY(p.meta_keywords)
    )
  ORDER BY
    CASE WHEN p.title ILIKE '%' || search_query || '%' THEN 0
         WHEN p.excerpt ILIKE '%' || search_query || '%' THEN 1
         ELSE 2
    END,
    p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add backup function
CREATE OR REPLACE FUNCTION backup_table(table_name text)
RETURNS void AS $$
DECLARE
  backup_table_name text;
BEGIN
  backup_table_name := table_name || '_backup_' || to_char(now(), 'YYYYMMDD_HH24MI');
  EXECUTE 'CREATE TABLE ' || backup_table_name || ' AS SELECT * FROM ' || table_name;
  
  -- Log backup
  INSERT INTO audit_logs (table_name, record_id, operation, changed_by)
  VALUES (
    table_name,
    gen_random_uuid(),
    'BACKUP',
    auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verify data integrity
DO $$ 
BEGIN
  -- Fix any orphaned records
  DELETE FROM comments WHERE post_id NOT IN (SELECT id FROM posts);
  DELETE FROM posts WHERE category_id NOT IN (SELECT id FROM categories);
  DELETE FROM posts WHERE author_id NOT IN (SELECT id FROM profiles);
  
  -- Ensure all posts have valid slugs
  UPDATE posts 
  SET slug = LOWER(REGEXP_REPLACE(COALESCE(slug, title), '[^a-z0-9]+', '-', 'g'))
  WHERE slug IS NULL OR slug = '';
  
  -- Set default reading times where missing
  UPDATE posts 
  SET reading_time = GREATEST(1, CEIL(LENGTH(content)::float / 1500))
  WHERE reading_time IS NULL OR reading_time < 1;
END $$;

COMMENT ON TABLE audit_logs IS 'Tracks all changes to important tables';
COMMENT ON FUNCTION validate_post() IS 'Ensures post data meets all requirements';
COMMENT ON FUNCTION increment_view_count(uuid) IS 'Safely increments post view count';
COMMENT ON FUNCTION get_post_stats(uuid) IS 'Returns consolidated stats for a post';
COMMENT ON FUNCTION search_posts(text) IS 'Performs optimized search across posts';
COMMENT ON FUNCTION backup_table(text) IS 'Creates a backup of the specified table';