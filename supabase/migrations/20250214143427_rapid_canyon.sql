/*
  # Fix Role Column and Policies

  1. Changes
    - Drop and recreate role column with proper constraints
    - Update admin user role
    - Fix RLS policies
    - Add proper indexes

  2. Security
    - Maintain RLS policies for proper access control
    - Ensure admin privileges are preserved
*/

-- First, ensure we can recreate the role column properly
ALTER TABLE profiles DROP COLUMN IF EXISTS role;

-- Add role column with proper constraints
ALTER TABLE profiles 
ADD COLUMN role text NOT NULL DEFAULT 'user';

-- Add check constraint after column exists
ALTER TABLE profiles 
ADD CONSTRAINT profiles_role_check 
CHECK (role IN ('user', 'admin'));

-- Update admin user
UPDATE profiles 
SET role = 'admin' 
WHERE id IN (
  SELECT profiles.id 
  FROM profiles 
  INNER JOIN auth.users ON profiles.id = auth.users.id 
  WHERE auth.users.email = 'advisor@strategyhub.com'
);

-- Drop existing policies
DROP POLICY IF EXISTS "Users can update own basic info" ON profiles;
DROP POLICY IF EXISTS "Admins have full access to profiles" ON profiles;

-- Create new policies
CREATE POLICY "Users can view all profiles"
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
  AND role = 'user'  -- Regular users can't change their role
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

-- Recreate index
DROP INDEX IF EXISTS idx_profiles_role;
CREATE INDEX idx_profiles_role ON profiles(role);