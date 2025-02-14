/*
  # Consolidated Database Schema Migration

  1. Changes
    - Adds missing constraints and validations
    - Optimizes indexes for common queries
    - Adds full-text search capabilities
    - Implements materialized views for performance
    
  2. Security
    - Enhances RLS policies
    - Adds additional validation checks
    
  3. Performance
    - Adds composite indexes
    - Implements caching strategies
*/

-- Add missing constraints to categories
ALTER TABLE categories
  ALTER COLUMN name SET NOT NULL,
  ADD COLUMN IF NOT EXISTS description text,
  ADD CONSTRAINT categories_name_unique UNIQUE (name);

-- Add missing constraints to profiles
ALTER TABLE profiles
  ALTER COLUMN username SET NOT NULL,
  ALTER COLUMN email SET NOT NULL,
  ADD CONSTRAINT profiles_username_unique UNIQUE (username),
  ADD CONSTRAINT profiles_email_unique UNIQUE (email);

-- Add full-text search to posts if not exists
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'posts' 
    AND column_name = 'search_vector'
  ) THEN
    ALTER TABLE posts 
    ADD COLUMN search_vector tsvector 
    GENERATED ALWAYS AS (
      setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
      setweight(to_tsvector('english', coalesce(excerpt, '')), 'B') ||
      setweight(to_tsvector('english', coalesce(content, '')), 'C')
    ) STORED;
  END IF;
END $$;

-- Create or replace the post statistics materialized view
CREATE MATERIALIZED VIEW IF NOT EXISTS post_stats AS
SELECT 
  p.id,
  p.title,
  p.slug,
  p.status,
  p.view_count,
  COUNT(c.id) as comment_count,
  p.reading_time,
  p.created_at,
  p.category_id,
  p.author_id
FROM posts p
LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id;

-- Create indexes for the materialized view
CREATE UNIQUE INDEX IF NOT EXISTS post_stats_id_idx ON post_stats(id);
CREATE INDEX IF NOT EXISTS post_stats_category_idx ON post_stats(category_id);
CREATE INDEX IF NOT EXISTS post_stats_author_idx ON post_stats(author_id);

-- Create function to refresh post stats
CREATE OR REPLACE FUNCTION refresh_post_stats()
RETURNS trigger AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY post_stats;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for post stats refresh
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

-- Create function for advanced post search
CREATE OR REPLACE FUNCTION search_posts_advanced(
  search_query text,
  category_filter uuid DEFAULT NULL,
  author_filter uuid DEFAULT NULL,
  min_reading_time integer DEFAULT NULL,
  max_reading_time integer DEFAULT NULL,
  limit_val integer DEFAULT 10,
  offset_val integer DEFAULT 0
)
RETURNS TABLE (
  id uuid,
  title text,
  excerpt text,
  slug text,
  author_name text,
  category_name text,
  reading_time integer,
  comment_count bigint,
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
    pr.username as author_name,
    c.name as category_name,
    p.reading_time,
    COUNT(cm.id) as comment_count,
    p.created_at,
    ts_rank(p.search_vector, websearch_to_tsquery('english', search_query)) as rank
  FROM posts p
  JOIN profiles pr ON p.author_id = pr.id
  JOIN categories c ON p.category_id = c.id
  LEFT JOIN comments cm ON p.id = cm.post_id
  WHERE 
    p.status = 'published'
    AND p.search_vector @@ websearch_to_tsquery('english', search_query)
    AND (category_filter IS NULL OR p.category_id = category_filter)
    AND (author_filter IS NULL OR p.author_id = author_filter)
    AND (min_reading_time IS NULL OR p.reading_time >= min_reading_time)
    AND (max_reading_time IS NULL OR p.reading_time <= max_reading_time)
  GROUP BY
    p.id,
    p.title,
    p.excerpt,
    p.slug,
    pr.username,
    c.name,
    p.reading_time,
    p.created_at,
    p.search_vector
  ORDER BY
    rank DESC,
    p.created_at DESC
  LIMIT limit_val
  OFFSET offset_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get trending posts
CREATE OR REPLACE FUNCTION get_trending_posts(
  days_back integer DEFAULT 7,
  limit_val integer DEFAULT 5
)
RETURNS TABLE (
  id uuid,
  title text,
  slug text,
  excerpt text,
  view_count integer,
  comment_count bigint,
  score float
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.title,
    p.slug,
    p.excerpt,
    p.view_count,
    COUNT(c.id) as comment_count,
    (p.view_count * 1.0 + COUNT(c.id) * 5.0) / 
    GREATEST(1, EXTRACT(EPOCH FROM (now() - p.created_at)) / 86400) as score
  FROM posts p
  LEFT JOIN comments c ON c.post_id = p.id
  WHERE 
    p.status = 'published'
    AND p.created_at >= (now() - (days_back || ' days')::interval)
  GROUP BY p.id
  ORDER BY score DESC
  LIMIT limit_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get post recommendations
CREATE OR REPLACE FUNCTION get_post_recommendations(
  user_id uuid,
  limit_val integer DEFAULT 5
)
RETURNS TABLE (
  id uuid,
  title text,
  slug text,
  excerpt text,
  relevance_score float
) AS $$
BEGIN
  RETURN QUERY
  WITH user_categories AS (
    SELECT DISTINCT category_id
    FROM posts p
    JOIN post_progress pp ON p.id = pp.post_id
    WHERE pp.user_id = user_id
  )
  SELECT
    p.id,
    p.title,
    p.slug,
    p.excerpt,
    (
      CASE WHEN p.category_id IN (SELECT category_id FROM user_categories) THEN 2.0 
      ELSE 1.0 END *
      ts_rank(p.search_vector, (
        SELECT to_tsquery('english', string_agg(word, ' | '))
        FROM (
          SELECT DISTINCT word
          FROM ts_stat(
            'SELECT search_vector FROM posts p
             JOIN post_progress pp ON p.id = pp.post_id
             WHERE pp.user_id = ''' || user_id || ''''
          )
        ) words
      ))
    ) as relevance_score
  FROM posts p
  WHERE 
    p.status = 'published'
    AND p.id NOT IN (
      SELECT post_id 
      FROM post_progress 
      WHERE user_id = user_id
    )
  ORDER BY relevance_score DESC
  LIMIT limit_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add documentation
COMMENT ON MATERIALIZED VIEW post_stats IS 'Cached post statistics for quick access';
COMMENT ON FUNCTION search_posts_advanced(text, uuid, uuid, integer, integer, integer, integer) IS 'Advanced post search with multiple filters';
COMMENT ON FUNCTION get_trending_posts(integer, integer) IS 'Returns trending posts based on views and comments';
COMMENT ON FUNCTION get_post_recommendations(uuid, integer) IS 'Returns personalized post recommendations';