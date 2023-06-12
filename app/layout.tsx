import './globals.css'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <div className="flex flex-col min-h-screen">
          <main className="flex-1 container max-w-screen-xl mx-auto px-5 py-10">
            {children}
          </main>

          <footer className="py-5 border-t">
            <div className="text-center text-sm text-gray-500">
              Copyright @ All rights reserved
            </div>
          </footer>
        </div>
      </body>
    </html>
  )
}
