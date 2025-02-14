/*
  # Fix profiles role column

  1. Changes
    - Add role column to profiles table if it doesn't exist
    - Set default admin user role
    - Add proper constraints and indexes
  
  2. Security
    - Ensure proper role-based access control
    - Maintain data integrity
*/

-- Add role column with proper constraints if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'role'
  ) THEN
    ALTER TABLE profiles 
    ADD COLUMN role text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin'));
  END IF;
END $$;

-- Set admin role for the advisor user
UPDATE profiles 
SET role = 'admin' 
WHERE id IN (
  SELECT profiles.id 
  FROM profiles 
  INNER JOIN auth.users ON profiles.id = auth.users.id 
  WHERE auth.users.email = 'advisor@strategyhub.com'
);

-- Create index for role lookups if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Update RLS policies for role-based access
DROP POLICY IF EXISTS "Users can update own non-role fields" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profile fields" ON profiles;

CREATE POLICY "Users can update own non-role fields"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id 
  AND role = OLD.role -- Prevent role changes by regular users
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