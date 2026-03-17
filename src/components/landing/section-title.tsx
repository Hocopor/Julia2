import type { ReactNode } from 'react'

interface SectionTitleProps {
  children: ReactNode
  invert?: boolean
  className?: string
}

export function SectionTitle({ children, invert = false, className }: SectionTitleProps) {
  const classes = ['sectionTitle', invert ? 'sectionTitleInverted' : '', className]
    .filter(Boolean)
    .join(' ')

  return <h2 className={classes}>{children}</h2>
}
