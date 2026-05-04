import sharp from 'sharp';

export class ThumbnailService {
  /**
   * Generates a tiny thumbnail from an image buffer.
   * Max 100px width, quality 60%.
   */
  static async generateThumbnail(imageBuffer: Buffer): Promise<Buffer> {
    return await sharp(imageBuffer)
      .resize({ width: 100, withoutEnlargement: true })
      .webp({ quality: 60 })
      .toBuffer();
  }

  /**
   * Checks if a mime type is an image that can be processed.
   */
  static isImage(mimeType: string): boolean {
    return ['image/jpeg', 'image/png', 'image/webp', 'image/gif'].includes(mimeType);
  }
}
