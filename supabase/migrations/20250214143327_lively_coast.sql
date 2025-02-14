-- Drop existing policies
DROP POLICY IF EXISTS "Users can update own non-role fields" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profile fields" ON profiles;

-- Create new policies with fixed conditions
CREATE POLICY "Users can update own basic info"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id 
  AND (
    (role IS NOT DISTINCT FROM current_setting('request.jwt.claims')::json->>'role')::text
  )
);

CREATE POLICY "Admins have full access to profiles"
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

-- Ensure proper indexes exist
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);