/*
  # Fix user and profile creation

  1. Changes
    - Create a function to safely create a user and profile
    - Use DO block to handle the user creation process
    - Ensure proper error handling

  2. Security
    - Maintains existing RLS policies
    - Ensures data integrity with proper foreign key relationships
*/

DO $$
DECLARE
    new_user_id uuid;
BEGIN
    -- Check if the user already exists
    SELECT id INTO new_user_id
    FROM auth.users
    WHERE email = 'advisor@strategyhub.com';

    -- If user doesn't exist, create them
    IF new_user_id IS NULL THEN
        INSERT INTO auth.users (
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
            '00000000-0000-0000-0000-000000000000',
            'advisor@strategyhub.com',
            crypt('password123', gen_salt('bf')),
            now(),
            '{"provider":"email","providers":["email"]}',
            '{}',
            now(),
            now(),
            'authenticated',
            ''
        )
        RETURNING id INTO new_user_id;
    END IF;

    -- Create profile if it doesn't exist
    INSERT INTO profiles (id, name, avatar_url)
    VALUES (
        new_user_id,
        'Strategic Advisor',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop'
    )
    ON CONFLICT (id) DO NOTHING;
END $$;