import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import compression from 'vite-plugin-compression';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react({
      // Enable React Fast Refresh
      fastRefresh: true,
      // Babel plugins for optimization
      babel: {
        plugins: [
          // Remove console.log in production
          process.env.NODE_ENV === 'production' && [
            'transform-remove-console',
            { exclude: ['error', 'warn'] }
          ]
        ].filter(Boolean)
      }
    }),

    // PWA Plugin
    VitePWA({
      registerType: 'prompt',
      includeAssets: ['favicon.ico', 'robots.txt', 'apple-touch-icon.png'],
      manifest: {
        name: 'Menschlichkeit Österreich',
        short_name: 'MenschlichkeitAT',
        description: 'Gemeinnütziger Verein für soziale Gerechtigkeit und Demokratie',
        theme_color: '#0d6efd',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable'
          }
        ]
      },
      workbox: {
        // Cache strategies
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365 // 1 year
              },
              cacheableResponse: {
                statuses: [0, 200]
              }
            }
          },
          {
            urlPattern: /^https:\/\/images\.unsplash\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'unsplash-images-cache',
              expiration: {
                maxEntries: 50,
                maxAgeSeconds: 60 * 60 * 24 * 30 // 30 days
              }
            }
          },
          {
            urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/,
            handler: 'CacheFirst',
            options: {
              cacheName: 'images-cache',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 * 30 // 30 days
              }
            }
          }
        ],
        skipWaiting: true,
        clientsClaim: true
      }
    }),

    // Gzip compression
    compression({
      algorithm: 'gzip',
      ext: '.gz'
    }),

    // Brotli compression (better than gzip)
    compression({
      algorithm: 'brotliCompress',
      ext: '.br'
    })
  ],

  // Build configuration
  build: {
    // Target modern browsers
    target: 'es2020',

    // Output directory
    outDir: 'dist',

    // Generate sourcemaps for debugging
    sourcemap: process.env.NODE_ENV === 'development',

    // Minify with esbuild (faster than terser)
    minify: 'esbuild',

    // Chunk size warnings
    chunkSizeWarningLimit: 1000,

    // Rollup options
    rollupOptions: {
      output: {
        // Manual chunks for better caching
        manualChunks: {
          // React ecosystem
          'react-vendor': ['react', 'react-dom'],

          // Motion/Framer
          'motion-vendor': ['motion/react'],

          // UI Components (shadcn)
          'ui-vendor': [
            './components/ui/button',
            './components/ui/card',
            './components/ui/dialog',
            './components/ui/input',
            './components/ui/label',
            './components/ui/select',
            './components/ui/toast',
            './components/ui/form'
          ],

          // Icons
          'icons-vendor': ['lucide-react'],

          // Game components (lazy loaded)
          'game-components': [
            './components/BridgeBuilding',
            './components/BridgeBuilding100',
            './components/Enhanced3DGameGraphics',
            './components/ImmersiveGameInterface'
          ],

          // Admin components (lazy loaded)
          'admin-components': [
            './components/AdminDashboard',
            './components/Moderation'
          ]
        },

        // Asset file names
        assetFileNames: (assetInfo) => {
          const info = assetInfo.name.split('.');
          const ext = info[info.length - 1];

          if (/\.(png|jpe?g|svg|gif|webp|avif)$/.test(assetInfo.name)) {
            return 'assets/images/[name]-[hash][extname]';
          }

          if (/\.css$/.test(assetInfo.name)) {
            return 'assets/css/[name]-[hash][extname]';
          }

          if (/\.(woff2?|eot|ttf|otf)$/.test(assetInfo.name)) {
            return 'assets/fonts/[name]-[hash][extname]';
          }

          return 'assets/[name]-[hash][extname]';
        },

        // Chunk file names
        chunkFileNames: 'assets/js/[name]-[hash].js',

        // Entry file names
        entryFileNames: 'assets/js/[name]-[hash].js'
      }
    },

    // CSS code splitting
    cssCodeSplit: true,

    // Reduce vendor chunk
    cssMinify: true
  },

  // Development server
  server: {
    port: 3000,
    host: true,
    open: true,
    cors: true,
    hmr: {
      overlay: true
    }
  },

  // Preview server
  preview: {
    port: 4173,
    host: true,
    open: true
  },

  // Optimizations
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'motion/react',
      'lucide-react'
    ],
    exclude: [
      // Exclude large packages from pre-bundling
    ]
  },

  // CSS preprocessing
  css: {
    postcss: {
      plugins: []
    },
    devSourcemap: true
  },

  // Environment variables
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
    __BUILD_DATE__: JSON.stringify(new Date().toISOString())
  }
});
