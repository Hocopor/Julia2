import { landingContent } from '../../lib/landing-content'

export function ContactsSection() {
  const { contacts } = landingContent

  return (
    <section className="contactsSection" aria-labelledby="contacts-title" id="contact">
      <div className="contactsImageWrap">
        <img className="contactsImage" src={contacts.imageSrc} alt={contacts.imageAlt} />
        <h2 className="contactsTitle" id="contacts-title">
          {contacts.title}
        </h2>
      </div>
      <div className="contactsLinks" aria-label="Контактные ссылки">
        {contacts.items.map((item, index) => {
          const isDevelopment = index === contacts.items.length - 1 // последний элемент - "РАЗРАБОТКА САЙТА"
          return (
            <a
              className={`contactsLink ${isDevelopment ? 'contactsLink--development' : ''}`}
              href={item.href}
              key={item.label}
              target={item.href.startsWith('http') ? '_blank' : undefined}
              rel={item.href.startsWith('http') ? 'noreferrer' : undefined}
              data-is-development={isDevelopment}
            >
              {item.label}
            </a>
          )
        })}
      </div>
    </section>
  )
}
