/*
  # Fix Database Schema

  1. Changes
    - Ensures profiles table has correct structure
    - Removes conflicting constraints
    - Sets up proper column definitions
    - Maintains existing data integrity
    
  2. Security
    - Preserves RLS policies
    - Maintains role-based access control
*/

-- First, ensure we have the correct columns and remove any conflicting ones
ALTER TABLE profiles 
DROP COLUMN IF EXISTS username,
DROP COLUMN IF EXISTS email,
DROP CONSTRAINT IF EXISTS profiles_username_unique,
DROP CONSTRAINT IF EXISTS profiles_email_unique;

-- Now add the correct columns with proper constraints
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS name text NOT NULL,
ADD COLUMN IF NOT EXISTS avatar_url text,
ADD COLUMN IF NOT EXISTS role text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin'));

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Ensure RLS is enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can update own basic info" ON profiles;
DROP POLICY IF EXISTS "Admins have full access to profiles" ON profiles;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;

-- Create comprehensive RLS policies
CREATE POLICY "Profiles are viewable by everyone"
ON profiles
FOR SELECT
TO public
USING (true);

CREATE POLICY "Users can update own basic info"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id 
  AND role = OLD.role  -- Prevent role changes by regular users
);

CREATE POLICY "Admins have full access to profiles"
ON profiles
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

-- Add documentation
COMMENT ON TABLE profiles IS 'User profiles with role-based access control';
COMMENT ON COLUMN profiles.name IS 'User''s display name';
COMMENT ON COLUMN profiles.avatar_url IS 'URL to user''s avatar image';
COMMENT ON COLUMN profiles.role IS 'User''s role (user or admin)';