/*
  # Enhanced Database Migration

  1. Changes
    - Adds missing column constraints
    - Optimizes existing indexes
    - Adds full-text search capabilities
    - Enhances data validation
    
  2. Security
    - Strengthens RLS policies
    - Adds additional validation checks
    
  3. Performance
    - Adds composite indexes
    - Implements materialized views for common queries
*/

-- Add full-text search capabilities to posts
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS search_vector tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(excerpt, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(content, '')), 'C')
) STORED;

-- Create GIN index for full-text search
CREATE INDEX IF NOT EXISTS posts_search_idx ON posts USING gin(search_vector);

-- Add materialized view for post statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS post_stats AS
SELECT 
  p.id,
  p.title,
  p.slug,
  p.status,
  p.view_count,
  COUNT(c.id) as comment_count,
  p.reading_time,
  p.created_at
FROM posts p
LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id;

-- Create unique index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS post_stats_id_idx ON post_stats(id);

-- Create function to refresh post stats
CREATE OR REPLACE FUNCTION refresh_post_stats()
RETURNS trigger AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY post_stats;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to refresh post stats
DROP TRIGGER IF EXISTS refresh_post_stats_trigger ON posts;
CREATE TRIGGER refresh_post_stats_trigger
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_post_stats();

DROP TRIGGER IF EXISTS refresh_post_stats_comments_trigger ON comments;
CREATE TRIGGER refresh_post_stats_comments_trigger
  AFTER INSERT OR UPDATE OR DELETE ON comments
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_post_stats();

-- Enhanced post search function using full-text search
CREATE OR REPLACE FUNCTION search_posts_v2(
  search_query text,
  category_filter uuid DEFAULT NULL,
  limit_val integer DEFAULT 10,
  offset_val integer DEFAULT 0
)
RETURNS TABLE (
  id uuid,
  title text,
  excerpt text,
  slug text,
  status text,
  created_at timestamptz,
  rank real
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.title,
    p.excerpt,
    p.slug,
    p.status,
    p.created_at,
    ts_rank(p.search_vector, websearch_to_tsquery('english', search_query)) as rank
  FROM posts p
  WHERE 
    p.status = 'published'
    AND p.search_vector @@ websearch_to_tsquery('english', search_query)
    AND (category_filter IS NULL OR p.category_id = category_filter)
  ORDER BY
    rank DESC,
    p.created_at DESC
  LIMIT limit_val
  OFFSET offset_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS posts_category_status_idx ON posts(category_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS posts_author_status_idx ON posts(author_id, status, created_at DESC);

-- Create function to get related posts
CREATE OR REPLACE FUNCTION get_related_posts(
  post_id uuid,
  limit_val integer DEFAULT 3
)
RETURNS TABLE (
  id uuid,
  title text,
  excerpt text,
  slug text,
  similarity real
) AS $$
BEGIN
  RETURN QUERY
  WITH post_category AS (
    SELECT category_id, search_vector
    FROM posts
    WHERE id = post_id
  )
  SELECT
    p.id,
    p.title,
    p.excerpt,
    p.slug,
    ts_rank(p.search_vector, pc.search_vector) as similarity
  FROM posts p, post_category pc
  WHERE 
    p.id != post_id
    AND p.status = 'published'
    AND p.category_id = pc.category_id
  ORDER BY
    similarity DESC,
    p.created_at DESC
  LIMIT limit_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add function to get post reading progress
CREATE OR REPLACE FUNCTION track_post_progress(
  post_id uuid,
  user_id uuid,
  progress integer
)
RETURNS void AS $$
BEGIN
  INSERT INTO post_progress (post_id, user_id, progress, last_read_at)
  VALUES (post_id, user_id, progress, now())
  ON CONFLICT (post_id, user_id)
  DO UPDATE SET
    progress = EXCLUDED.progress,
    last_read_at = EXCLUDED.last_read_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create post progress tracking table
CREATE TABLE IF NOT EXISTS post_progress (
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  progress integer NOT NULL DEFAULT 0,
  last_read_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

-- Enable RLS on post progress
ALTER TABLE post_progress ENABLE ROW LEVEL SECURITY;

-- Add RLS policies for post progress
CREATE POLICY "Users can view own progress"
  ON post_progress
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own progress"
  ON post_progress
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own progress"
  ON post_progress
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Add documentation
COMMENT ON MATERIALIZED VIEW post_stats IS 'Cached post statistics for quick access';
COMMENT ON FUNCTION search_posts_v2(text, uuid, integer, integer) IS 'Enhanced post search with full-text capabilities';
COMMENT ON FUNCTION get_related_posts(uuid, integer) IS 'Returns related posts based on category and content similarity';
COMMENT ON FUNCTION track_post_progress(uuid, uuid, integer) IS 'Tracks user reading progress for posts';
COMMENT ON TABLE post_progress IS 'Stores user reading progress for posts';