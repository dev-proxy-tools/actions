import { test, expect } from '@playwright/test';

test.describe('Blog Posts Page', () => {

  test('should display loading state initially', async ({ page }) => {
    // Start navigation but don't wait for it to complete
    const navigationPromise = page.goto('/');

    // Assert that the loading text appears
    await expect(page.getByText('Loading posts...')).toBeVisible();

    // Wait for navigation to complete
    await navigationPromise;

    // Assert that the loading text disappears after posts load
    await expect(page.getByText('Loading posts...')).not.toBeVisible();

    // Check that posts are eventually loaded
    await expect(page.locator('#posts article')).toHaveCount(5, { timeout: 10000 });
  });

  test('should display all expected blog post titles', async ({ page }) => {
    await page.goto('/');
    
    // Wait for posts to load
    await expect(page.locator('#posts article')).toHaveCount(5, { timeout: 10000 });
    
    // Check all expected blog post titles
    const expectedTitles = [
      'Getting Started with Dev Proxy',
      'Building Better APIs with Mocking',
      'CI/CD Integration with GitHub Actions',
      'Advanced Configuration Techniques',
      'Debugging Network Issues'
    ];
    
    for (const title of expectedTitles) {
      await expect(page.locator('#posts')).toContainText(title);
    }
  });

  test('should have proper styling and layout', async ({ page }) => {
    await page.goto('/');
    
    // Wait for posts to load
    await expect(page.locator('#posts article')).toHaveCount(5, { timeout: 10000 });
    
    // Check that the page has proper styling
    const postsContainer = page.locator('#posts');
    await expect(postsContainer).toBeVisible();
    
    // Check that articles have proper hover effects (by checking CSS classes)
    const firstArticle = page.locator('#posts article').first();
    await expect(firstArticle).toHaveClass(/hover:shadow-md/);
    
    // Check that "Read more" buttons are present
    const readMoreButtons = page.locator('button:has-text("Read more")');
    await expect(readMoreButtons).toHaveCount(5);
  });

});
