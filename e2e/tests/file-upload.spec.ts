import { test, expect } from "@playwright/test";
import * as path from "path";
import * as fs from "fs";
import * as os from "os";

test.describe("File Upload", () => {
  test("uploads a file and shows byte count", async ({ page }) => {
    await page.goto("/examples/file-upload");
    await expect(page.locator("#demo")).toBeVisible();

    // Create a temporary file with known content
    const tmpDir = os.tmpdir();
    const tmpFile = path.join(tmpDir, "test-upload.txt");
    const content = "Hello, this is a test file for upload!";
    fs.writeFileSync(tmpFile, content);

    // Upload the file
    const fileInput = page.locator("#file-input");
    await fileInput.setInputFiles(tmpFile);

    // Click upload
    await page.getByRole("button", { name: "Upload" }).click();

    // Should show received bytes
    await expect(page.locator("#demo")).toContainText("Received", {
      timeout: 10000,
    });

    // Clean up
    fs.unlinkSync(tmpFile);
  });
});
