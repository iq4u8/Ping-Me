import db from '../utils/db.js';

async function updateSchema() {
  console.log('🚀 Updating database schema with privacy columns...');
  
  const columns = [
    "ALTER TABLE users ADD COLUMN last_seen_privacy TEXT CHECK(last_seen_privacy IN ('everyone', 'contacts', 'nobody')) DEFAULT 'everyone'",
    "ALTER TABLE users ADD COLUMN profile_photo_privacy TEXT CHECK(profile_photo_privacy IN ('everyone', 'contacts', 'nobody')) DEFAULT 'everyone'",
    "ALTER TABLE users ADD COLUMN phone_visible INTEGER DEFAULT 0",
    "ALTER TABLE users ADD COLUMN read_receipts_enabled INTEGER DEFAULT 1",
    "ALTER TABLE users ADD COLUMN notifications_enabled INTEGER DEFAULT 1",
    "ALTER TABLE users ADD COLUMN deletion_scheduled_at DATETIME",
    "ALTER TABLE sessions ADD COLUMN fcm_token TEXT"
  ];

  for (const sql of columns) {
    try {
      await db.execute(sql);
      console.log(`✅ Executed: ${sql.substring(0, 40)}...`);
    } catch (err: any) {
      if (err.message.includes('duplicate column name') || err.message.includes('already exists')) {
        console.log(`ℹ️ Column already exists, skipping.`);
      } else {
        console.error(`❌ Error executing: ${sql}`);
        console.error(err.message);
      }
    }
  }

  console.log('✨ Schema update process finished.');
}

updateSchema();
