-- Supabase Storage Setup for Rental App
-- Run this SQL in your Supabase SQL Editor to create storage buckets and policies

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('car-images', 'car-images', true),
  ('rental-files', 'rental-files', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for car-images bucket
CREATE POLICY "Users can upload car images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'car-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Anyone can view car images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'car-images');

CREATE POLICY "Users can update their car images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'car-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their car images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'car-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Storage policies for rental-files bucket
CREATE POLICY "Users can upload rental files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'rental-files' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Anyone can view rental files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'rental-files');

CREATE POLICY "Users can update their rental files"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'rental-files' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their rental files"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'rental-files' AND auth.uid()::text = (storage.foldername(name))[1]);
