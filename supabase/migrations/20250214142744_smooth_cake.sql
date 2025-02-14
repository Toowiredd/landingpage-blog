/*
  # Fix profiles RLS policies

  1. Changes
    - Fix RLS policy for updating profiles
    - Ensure proper role checks
  
  2. Security
    - Allow users to update their own non-role fields
    - Allow admins to update all fields
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own non-role fields" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profile fields" ON profiles;

-- Create new policies with fixed conditions
CREATE POLICY "Users can update own non-role fields"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id 
  AND role = OLD.role -- Use direct comparison instead of NEW reference
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