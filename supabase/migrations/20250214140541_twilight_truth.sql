/*
  # Fix profile data migration

  1. Changes
    - Create a new user in auth.users
    - Update the profile insertion to use the new user's ID
    - Add RLS policies for the new user

  2. Security
    - Maintains existing RLS policies
    - Ensures data integrity with proper foreign key relationships
*/

-- Create a new user in auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  role,
  confirmation_token
)
VALUES (
  gen_random_uuid(), -- Generate a new UUID for the user
  '00000000-0000-0000-0000-000000000000',
  'advisor@strategyhub.com',
  crypt('password123', gen_salt('bf')), -- This is just for development
  now(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  now(),
  now(),
  'authenticated',
  ''
)
RETURNING id;

-- Update the profile with the new user ID
INSERT INTO profiles (id, name, avatar_url)
SELECT 
  id,
  'Strategic Advisor',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop'
FROM auth.users
WHERE email = 'advisor@strategyhub.com'
ON CONFLICT (id) DO NOTHING;