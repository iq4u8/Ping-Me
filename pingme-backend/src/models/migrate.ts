import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import db from '../utils/db.js';
import { env } from '../config/env.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function migrate() {
  console.log('🚀 Starting database migration...');
  console.log('📡 Connecting to:', env.DATABASE_URL);
  console.log('🔑 Auth Token length:', env.DATABASE_AUTH_TOKEN?.length || 0);

  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');

    // Split schema into individual statements
    // We filter out empty lines and trim whitespace
    const statements = schema
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0);

    console.log(`📝 Found ${statements.length} SQL statements to execute.`);

    for (const statement of statements) {
      const tableNameMatch = statement.match(/CREATE TABLE IF NOT EXISTS (\w+)/i);
      const tableName = tableNameMatch ? tableNameMatch[1] : 'unknown';
      
      try {
        await db.execute(statement);
        console.log(`✅ Table '${tableName}' processed successfully.`);
      } catch (err: any) {
        console.error(`❌ Error executing statement for table '${tableName}':`);
        console.error(JSON.stringify(err, null, 2));
        throw err;
      }
    }

    console.log('✨ Migration completed successfully!');
  } catch (error: any) {
    console.error('💥 Migration failed:', error.message);
    process.exit(1);
  }
}

migrate();
