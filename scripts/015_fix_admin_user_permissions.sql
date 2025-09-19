-- Check if the admin user exists and fix their permissions
-- First, let's see what users exist
SELECT id, email, role, permissions FROM user_profiles;

-- Update the admin user to have proper admin role and permissions
UPDATE user_profiles 
SET 
  role = 'admin',
  permissions = '{
    "canManageProducts": true,
    "canManageCategories": true,
    "canViewReports": true,
    "canManageShopkeepers": true,
    "canProcessReturns": true,
    "canManageStock": true,
    "canManageUsers": true,
    "canAccessAllTabs": true
  }'::jsonb,
  updated_at = NOW()
WHERE email = 'abug@hzshop.com';

-- If the user doesn't exist, create them
INSERT INTO user_profiles (id, email, role, permissions, created_at, updated_at, created_by)
SELECT 
  auth.uid(),
  'abug@hzshop.com',
  'admin',
  '{
    "canManageProducts": true,
    "canManageCategories": true,
    "canViewReports": true,
    "canManageShopkeepers": true,
    "canProcessReturns": true,
    "canManageStock": true,
    "canManageUsers": true,
    "canAccessAllTabs": true
  }'::jsonb,
  NOW(),
  NOW(),
  auth.uid()
FROM auth.users 
WHERE email = 'abug@hzshop.com'
AND NOT EXISTS (
  SELECT 1 FROM user_profiles WHERE email = 'abug@hzshop.com'
);

-- Verify the update
SELECT id, email, role, permissions FROM user_profiles WHERE email = 'abug@hzshop.com';
