/*
  # Fix blog data fetching issues

  1. Changes
    - Add missing indexes for performance optimization
    - Update RLS policies to ensure proper data access
    - Fix any potential null values in required fields
  
  2. Security
    - Ensure proper RLS policies for public access
    - Maintain data integrity
*/

-- Add additional indexes for performance if they don't exist
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_published_status ON posts(status) WHERE status = 'published';

-- Ensure proper RLS policies
DROP POLICY IF EXISTS "Public can view published posts" ON posts;
CREATE POLICY "Public can view published posts"
ON posts
FOR SELECT
TO public
USING (
  status = 'published' 
  AND author_id IS NOT NULL 
  AND category_id IS NOT NULL
);

-- Fix any potential null values in required fields
UPDATE posts 
SET status = 'published' 
WHERE status IS NULL;

-- Add policy for admin access if it doesn't exist
DROP POLICY IF EXISTS "Admins have full access to posts" ON posts;
CREATE POLICY "Admins have full access to posts"
ON posts
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- Ensure proper cascading deletes for related tables
ALTER TABLE comments 
DROP CONSTRAINT IF EXISTS comments_post_id_fkey,
ADD CONSTRAINT comments_post_id_fkey 
  FOREIGN KEY (post_id) 
  REFERENCES posts(id) 
  ON DELETE CASCADE;