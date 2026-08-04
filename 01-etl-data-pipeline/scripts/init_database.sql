/*
================================================
Create Database and Schemas
================================================
Script Purpose:
  This script creates a new database named 'BrazilianECommerce' Additionally, the script sets up three schemas
  within the database: 'bronze', 'silver', 'gold'.
*/

USE master;
GO

--Create database 'BrazilianECommerce'
CREATE DATABASE BrazilianECommerce;

USE BrazilianECommerce;

--Create schemas for bronze, silver, and gold layers
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
