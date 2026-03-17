import type { IssueTone } from '../../lib/landing-content'

interface IssueCardProps {
  number: string
  title: string
  description: string
  tone: IssueTone
}

export function IssueCard({ number, title, description, tone }: IssueCardProps) {
  const classes = ['issueCard', tone === 'light' ? 'issueCardLight' : 'issueCardDark'].join(' ')

  return (
    <article className={classes}>
      <div className="issueCardHeader">
        <h3 className="issueCardTitle">{title}</h3>
        <span className="issueCardNumber">{number}</span>
      </div>
      <p className="issueCardDescription">{description}</p>
    </article>
  )
}
