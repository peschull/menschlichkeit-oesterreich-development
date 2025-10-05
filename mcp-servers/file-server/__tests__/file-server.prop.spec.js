const fc = require('fast-check');
const os = require('os');
const path = require('path');
const fs = require('fs').promises;
const FileServerMCP = require('..');

describe('FileServerMCP property tests', () => {
  test('resolveSafePath rejects traversal and hidden paths', async () => {
    const s = new FileServerMCP();
    const base = await fs.mkdtemp(path.join(os.tmpdir(), 'mcp-prop-'));
    await fs.mkdir(path.join(base, 'dir'), { recursive: true });
    await fs.writeFile(path.join(base, 'dir', 'file.txt'), 'ok');
    await fs.writeFile(path.join(base, 'file.txt'), 'ok');

    await fc.assert(
      fc.asyncProperty(
        fc.oneof(
          fc.constant('..'),
          fc.constant('../file.txt'),
          fc.constant('..\\file.txt'),
          fc.constant('/abs/path'),
          fc.constant('.hidden/file.txt'),
          fc.constant('dir/../file.txt')
        ),
        async bad => {
          let threw = false;
          try {
            await s.resolveSafePath(base, bad);
          } catch {
            threw = true;
          }
          expect(threw).toBe(true);
        }
      ),
      { numRuns: 50 }
    );
  });
});

