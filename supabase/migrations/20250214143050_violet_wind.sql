/*
  # Fix blog schema and policies

  1. Changes
    - Ensure all necessary columns exist
    - Fix RLS policies for blog-related tables
    - Add missing indexes for performance
  
  2. Security
    - Update RLS policies to ensure proper access
*/

-- Ensure posts table has all required columns
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'published',
ADD COLUMN IF NOT EXISTS slug text;

-- Create unique index on slug if it doesn't exist
CREATE UNIQUE INDEX IF NOT EXISTS posts_slug_idx ON posts(slug) WHERE slug IS NOT NULL;

-- Update RLS policies for posts
DROP POLICY IF EXISTS "Public can view published posts" ON posts;
CREATE POLICY "Public can view published posts"
ON posts
FOR SELECT
TO public
USING (status = 'published');

-- Ensure profiles have proper RLS
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;
CREATE POLICY "Profiles are viewable by everyone"
ON profiles
FOR SELECT
TO public
USING (true);

-- Ensure categories have proper RLS
DROP POLICY IF EXISTS "Categories are viewable by everyone" ON categories;
CREATE POLICY "Categories are viewable by everyone"
ON categories
FOR SELECT
TO public
USING (true);

-- Add missing indexes for performance
CREATE INDEX IF NOT EXISTS posts_created_at_idx ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS posts_category_id_idx ON posts(category_id);
CREATE INDEX IF NOT EXISTS posts_author_id_idx ON posts(author_id);

-- Update any null slugs with a default value based on title
UPDATE posts 
SET slug = LOWER(REGEXP_REPLACE(title, '[^a-zA-Z0-9]+', '-', 'g'))
WHERE slug IS NULL;

-- Make slug required after fixing any null values
ALTER TABLE posts ALTER COLUMN slug SET NOT NULL;