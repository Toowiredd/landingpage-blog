/*
  # Add role column to profiles table

  1. Changes
    - Add role column to profiles table
    - Update RLS policies for admin access
  
  2. Security
    - Enable RLS on profiles table
    - Add policies for role-based access
*/

-- Add role column if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin'));

-- Update existing admin user
UPDATE profiles 
SET role = 'admin' 
WHERE email = 'advisor@strategyhub.com';

-- Update RLS policies for profiles
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Allow users to update their own non-role fields
CREATE POLICY "Users can update own non-role fields"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id 
  AND (
    -- Only allow updating non-role fields
    NEW.role IS NULL 
    OR NEW.role = OLD.role
  )
);

-- Allow admins to update any profile including roles
CREATE POLICY "Admins can update all profile fields"
ON profiles
FOR UPDATE
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

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);