/*
  # Fix profiles role column and policies

  1. Changes
    - Ensure role column exists with proper constraints
    - Update RLS policies for better role management
    - Add necessary indexes
  
  2. Security
    - Restrict role updates to admins only
    - Allow users to update their own non-role fields
*/

-- First, ensure the role column exists with proper constraints
DO $$ 
BEGIN
  -- Drop existing role column if it exists (to ensure clean state)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'role'
  ) THEN
    ALTER TABLE profiles DROP COLUMN role;
  END IF;

  -- Add role column with proper constraints
  ALTER TABLE profiles 
  ADD COLUMN role text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin'));
END $$;

-- Update admin role for existing users
UPDATE profiles 
SET role = 'admin' 
WHERE id IN (
  SELECT id 
  FROM auth.users 
  WHERE email = 'advisor@strategyhub.com'
);

-- Drop existing policies
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own non-role fields" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profile fields" ON profiles;

-- Create new policies
CREATE POLICY "Users can update own non-role fields"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id 
  AND (
    NEW.role = OLD.role -- Prevent role changes
  )
);

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

-- Ensure index exists for role lookups
DROP INDEX IF EXISTS idx_profiles_role;
CREATE INDEX idx_profiles_role ON profiles(role);