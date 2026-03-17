import { landingContent } from '../../lib/landing-content'
import { IssueCard } from './issue-card'
import { SectionTitle } from './section-title'

export function IssuesSection() {
  const { issues } = landingContent
  const [first, second, third, fourth] = issues.items

  return (
    <section className="issuesSection" aria-labelledby="issues-title">
      <SectionTitle invert className="issuesTitle">
        <span id="issues-title">{issues.title}</span>
      </SectionTitle>
      <div className="issuesFrame">
        <IssueCard {...first} />
        <IssueCard {...second} />
        <img className="issuesFlower" src={issues.flowerImageSrc} alt={issues.flowerImageAlt} />
        <IssueCard {...third} />
        <IssueCard {...fourth} />
      </div>
    </section>
  )
}
