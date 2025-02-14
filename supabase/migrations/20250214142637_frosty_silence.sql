/*
  # Fix profiles role column

  1. Changes
    - Add role column to profiles table if it doesn't exist
    - Set admin role for the advisor user
  
  2. Security
    - No changes to security policies
*/

-- Add role column if it doesn't exist
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

-- Update admin role for the advisor
UPDATE profiles 
SET role = 'admin' 
WHERE id IN (
  SELECT id 
  FROM auth.users 
  WHERE email = 'advisor@strategyhub.com'
);

-- Create index for role lookups if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);