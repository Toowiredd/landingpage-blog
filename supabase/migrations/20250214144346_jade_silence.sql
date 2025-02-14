/*
  # Fix Profiles Schema

  1. Changes
    - Removes username constraint (using name instead)
    - Ensures proper email constraints
    - Maintains existing data integrity
    
  2. Security
    - Preserves existing RLS policies
    - Maintains role-based access control
*/

-- Remove any existing constraints that might conflict
ALTER TABLE profiles 
DROP CONSTRAINT IF EXISTS profiles_username_unique,
DROP CONSTRAINT IF EXISTS profiles_email_unique;

-- Ensure email is unique and required
ALTER TABLE profiles
ADD CONSTRAINT profiles_email_unique UNIQUE (email);

-- Update existing constraints for the name field
ALTER TABLE profiles
ALTER COLUMN name SET NOT NULL;

-- Create index for email lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- Ensure proper RLS policies
DROP POLICY IF EXISTS "Users can update own basic info" ON profiles;
DROP POLICY IF EXISTS "Admins have full access to profiles" ON profiles;

-- Recreate policies with correct field references
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

-- Add documentation
COMMENT ON TABLE profiles IS 'User profiles with role-based access control';
COMMENT ON COLUMN profiles.name IS 'User''s display name';
COMMENT ON COLUMN profiles.email IS 'User''s email address (unique)';
COMMENT ON COLUMN profiles.role IS 'User''s role (user or admin)';