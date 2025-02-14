/*
  # Blog System Update

  1. Changes
    - Add `status` column to posts table for draft/published state
    - Add `published_at` column for scheduled publishing
    - Update RLS policies for admin access

  2. Security
    - Enable RLS
    - Add policies for admin access
    - Maintain public read access for published posts
*/

-- Add new columns to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
ADD COLUMN IF NOT EXISTS published_at timestamptz;

-- Update RLS policies for posts
DROP POLICY IF EXISTS "Posts are viewable by everyone" ON posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON posts;
DROP POLICY IF EXISTS "Users can update own posts" ON posts;

-- Public can only view published posts
CREATE POLICY "Public can view published posts"
ON posts
FOR SELECT
TO public
USING (status = 'published' AND (published_at IS NULL OR published_at <= now()));

-- Admins can do all operations
CREATE POLICY "Admins have full access"
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

-- Add role column to profiles if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'role'
  ) THEN
    ALTER TABLE profiles ADD COLUMN role text DEFAULT 'user';
  END IF;
END $$;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_posts_status_published_at ON posts(status, published_at);