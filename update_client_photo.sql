-- Update client photo
-- First, let's see all clients
SELECT id, username, email, firstName, lastName, photos FROM clients;

-- Update the photo for a specific client (replace CLIENT_ID with the actual ID)
-- UPDATE clients SET photos = 'uploads/1764242735826-icon.png' WHERE id = CLIENT_ID;

-- Or update by email
-- UPDATE clients SET photos = 'uploads/1764242735826-icon.png' WHERE email = 'user@example.com';

-- Verify the update
-- SELECT id, username, email, photos FROM clients WHERE id = CLIENT_ID;
