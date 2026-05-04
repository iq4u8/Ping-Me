import db from '../utils/db.js';

export class PrivacyService {
  /**
   * Filters user profile data based on their privacy settings and blocking status.
   */
  static async filterProfile(targetUserId: string, requestingUserId: string): Promise<any> {
    // 1. Check if requesting user is blocked by target user
    const blocked = await db.execute({
      sql: 'SELECT 1 FROM blocked_users WHERE user_id = ? AND blocked_user_id = ?',
      args: [targetUserId, requestingUserId],
    });

    const isBlocked = blocked.rows.length > 0;

    // 2. Fetch target user's profile and settings
    const result = await db.execute({
      sql: 'SELECT * FROM users WHERE id = ?',
      args: [targetUserId],
    });

    if (result.rows.length === 0) return null;
    const user = result.rows[0] as any;

    if (isBlocked) {
      // Return minimal info if blocked
      return {
        id: user.id,
        username: user.username,
        display_name: user.display_name,
        avatar_url: null,
        bio: null,
        status: 'offline',
        last_seen: null,
      };
    }

    // 3. Check if they are contacts (needed for 'contacts' privacy setting)
    const contacts = await db.execute({
      sql: 'SELECT 1 FROM contacts WHERE user_id = ? AND contact_user_id = ?',
      args: [targetUserId, requestingUserId],
    });
    const isContact = contacts.rows.length > 0;

    const profile: any = {
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      bio: user.bio,
    };

    // Apply last_seen privacy
    if (this.canSee(user.last_seen_privacy, isContact)) {
      profile.last_seen = user.last_seen;
      profile.status = user.status;
    } else {
      profile.last_seen = null;
      profile.status = 'hidden';
    }

    // Apply profile photo privacy
    if (this.canSee(user.profile_photo_privacy, isContact)) {
      profile.avatar_url = user.avatar_url;
    } else {
      profile.avatar_url = null;
    }

    // Apply phone visibility
    if (user.phone_visible === 1) {
      profile.phone = user.phone;
    } else {
      profile.phone = null;
    }

    return profile;
  }

  private static canSee(setting: string, isContact: boolean): boolean {
    if (setting === 'everyone') return true;
    if (setting === 'contacts') return isContact;
    return false; // 'nobody'
  }
}
