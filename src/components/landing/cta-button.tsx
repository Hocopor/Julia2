interface CTAButtonProps {
  href: string
  label: string
  className?: string
}

export function CTAButton({ href, label, className }: CTAButtonProps) {
  const classes = ['ctaButton', className].filter(Boolean).join(' ')

  return (
    <a className={classes} href={href}>
      {label}
    </a>
  )
}
