-- Supabase Database Schema for Rental App
-- Run this SQL in your Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Cars Table
CREATE TABLE IF NOT EXISTS cars (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vehicle_number TEXT NOT NULL,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  color TEXT NOT NULL,
  transmission TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  owner_phone_number TEXT NOT NULL,
  image_path TEXT,
  price_per_day DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rentals Table
CREATE TABLE IF NOT EXISTS rentals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  car_id UUID REFERENCES cars(id) ON DELETE SET NULL,
  vehicle_number TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  rent_to_person TEXT NOT NULL,
  contact_number TEXT,
  email TEXT,
  address TEXT,
  notes TEXT,
  rent_from_date TIMESTAMPTZ NOT NULL,
  rent_to_date TIMESTAMPTZ NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  image_path TEXT,
  document_path TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  actual_return_date TIMESTAMPTZ,
  is_return_approved BOOLEAN DEFAULT FALSE,
  is_commission_based BOOLEAN DEFAULT FALSE,
  is_cancelled BOOLEAN DEFAULT FALSE,
  cancellation_amount DECIMAL(10, 2)
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_cars_user_id ON cars(user_id);
CREATE INDEX IF NOT EXISTS idx_cars_vehicle_number ON cars(vehicle_number);
CREATE INDEX IF NOT EXISTS idx_rentals_user_id ON rentals(user_id);
CREATE INDEX IF NOT EXISTS idx_rentals_vehicle_number ON rentals(vehicle_number);
CREATE INDEX IF NOT EXISTS idx_rentals_dates ON rentals(rent_from_date, rent_to_date);
CREATE INDEX IF NOT EXISTS idx_rentals_created_at ON rentals(created_at DESC);

-- Row Level Security (RLS) Policies
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE rentals ENABLE ROW LEVEL SECURITY;

-- Cars RLS Policies
-- Users can only see their own cars
CREATE POLICY "Users can view their own cars"
  ON cars FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own cars
CREATE POLICY "Users can insert their own cars"
  ON cars FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own cars
CREATE POLICY "Users can update their own cars"
  ON cars FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own cars
CREATE POLICY "Users can delete their own cars"
  ON cars FOR DELETE
  USING (auth.uid() = user_id);

-- Rentals RLS Policies
-- Users can only see their own rentals
CREATE POLICY "Users can view their own rentals"
  ON rentals FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own rentals
CREATE POLICY "Users can insert their own rentals"
  ON rentals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own rentals
CREATE POLICY "Users can update their own rentals"
  ON rentals FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own rentals
CREATE POLICY "Users can delete their own rentals"
  ON rentals FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to auto-update updated_at
CREATE TRIGGER update_cars_updated_at
  BEFORE UPDATE ON cars
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rentals_updated_at
  BEFORE UPDATE ON rentals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
