/*
  # Fix RLS Policies

  1. Changes
    - Removes problematic RLS policies
    - Creates new policies with correct syntax
    - Maintains existing security model
    
  2. Security
    - Preserves role-based access control
    - Maintains data access restrictions
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can update own basic info" ON profiles;
DROP POLICY IF EXISTS "Admins have full access to profiles" ON profiles;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;

-- Create new policies with correct syntax
CREATE POLICY "Profiles are viewable by everyone"
ON profiles
FOR SELECT
TO public
USING (true);

CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id
  AND (
    CASE 
      WHEN auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin') THEN true
      ELSE role = (SELECT role FROM profiles WHERE id = auth.uid())
    END
  )
);

CREATE POLICY "Admins have full access"
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
COMMENT ON COLUMN profiles.role IS 'User role (admin or user)';