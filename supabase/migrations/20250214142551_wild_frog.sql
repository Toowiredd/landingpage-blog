/*
  # Fix admin role update

  1. Changes
    - Update admin role using auth.users email instead of non-existent profiles.email
  
  2. Security
    - No changes to security policies
*/

-- Update admin role using auth.users email
UPDATE profiles 
SET role = 'admin' 
WHERE id IN (
  SELECT id 
  FROM auth.users 
  WHERE email = 'advisor@strategyhub.com'
);

-- Create index for role lookups if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);