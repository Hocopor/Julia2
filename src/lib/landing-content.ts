const fallbackLinks = {
  cta: '#contact',
  whatsapp: 'https://wa.me/placeholder',
  telegram: 'https://t.me/placeholder',
  vk: 'https://vk.com/placeholder',
  developedBy: '#development',
} as const

export const links = {
  cta: import.meta.env.VITE_CTA_URL || fallbackLinks.cta,
  whatsapp: import.meta.env.VITE_WHATSAPP_URL || fallbackLinks.whatsapp,
  telegram: import.meta.env.VITE_TELEGRAM_URL || fallbackLinks.telegram,
  vk: import.meta.env.VITE_VK_URL || fallbackLinks.vk,
  developedBy: import.meta.env.VITE_DEVELOPED_BY_URL || fallbackLinks.developedBy,
} as const

function assetPath(fileName: string) {
  return `${import.meta.env.BASE_URL}assets/${fileName}`
}

export const landingContent = {
  hero: {
    role: 'ПСИХОЛОГ, КПТ-ТЕРАПЕВТ',
    firstName: 'ЮЛИЯ',
    lastName: 'КИМЛАЧ',
    quote:
      'ПОМОГУ РАЗРЕШИТЬ ВНУТРЕННИЕ КОНФЛИКТЫ, РАЗОБРАТЬСЯ В СЕБЕ И СВОИХ ЧУВСТВАХ И ПРИБЛИЗИТЬСЯ К НАСТОЯЩЕМУ СПОКОЙСТВИЮ.',
    ctaLabel: 'ЗАПИСАТЬСЯ НА КОНСУЛЬТАЦИЮ',
    imageSrc: assetPath('hero-photo-v3.png'),
    imageAlt: 'Юлия лежит на светлом диване',
  },
  about: {
    title: 'ОБО МНЕ',
    text:
      'Меня зовут Юлия, я практикующий психолог-консультант, в своей работе я опираюсь на доказательные методы психотерапии и работаю преимущественно в когнитивно-поведенческом подходе (КПТ).',
    imageSrc: assetPath('about-photo-v3.png'),
    imageAlt: 'Портрет Юлии в светлом интерьере',
  },
  issues: {
    title: 'С КАКИМИ ПРОБЛЕМАМИ Я РАБОТАЮ:',
    flowerImageSrc: assetPath('issues-flower-v2.png'),
    flowerImageAlt: 'Светлый цветок на длинном стебле',
    items: [
      {
        number: '/1',
        title: 'ТРЕВОГА:',
        description: 'Повышенная тревожность, чувство беспокойства, панические атаки.',
        tone: 'dark',
      },
      {
        number: '/2',
        title: 'ДЕПРЕССИЯ:',
        description:
          'Апатия, депрессивные состояния, потеря интереса к жизни, подавленность, раздражительность, отсутствие сил и энергии.',
        tone: 'light',
      },
      {
        number: '/3',
        title: 'СЛОЖНОСТИ В ОТНОШЕНИЯХ:',
        description:
          'Конфликты с партнером, трудные взаимоотношения с родителями, непройденная сепарация, зависимая привязанность.',
        tone: 'dark',
      },
      {
        number: '/4',
        title: 'ПРОБЛЕМЫ С САМООЦЕНКОЙ:',
        description:
          'Трудности в личной реализации, неуверенность в себе, страх осуждения, зависимость от мнения окружающих.',
        tone: 'dark',
      },
    ],
  },
  pricing: {
    title: 'УСЛОВИЯ РАБОТЫ',
    flowerImageSrc: assetPath('pricing-flower-v2.png'),
    flowerImageAlt: 'Крупный светлый цветок',
    seaImageSrc: assetPath('sea-photo-v2.png'),
    seaImageAlt: 'Спокойный морской пейзаж',
    note: [
      'Консультации проходят в онлайн-формате по видеосвязи в ЯндексТелемост',
      'Есть возможность проведения очных консультаций в Краснодаре, для получения более подробной информации можно написать мне в личные сообщения.',
    ],
    items: [
      {
        number: '/1',
        title: 'КОНСУЛЬТАЦИЯ',
        rows: [
          { label: 'Время:', value: '50 МИНУТ' },
          { label: 'Стоимость:', value: '3000 РУБЛЕЙ' },
        ],
        ctaLabel: 'ЗАПИСАТЬСЯ НА КОНСУЛЬТАЦИЮ',
      },
      {
        number: '/2',
        title: 'ПАКЕТ (4 КОНСУЛЬТАЦИИ)',
        rows: [
          { label: 'Время:', value: '50 МИН × 4' },
          { label: 'Стоимость:', value: '11000 РУБЛЕЙ' },
        ],
        ctaLabel: 'ЗАПИСАТЬСЯ НА КОНСУЛЬТАЦИЮ',
      },
      {
        number: '/3',
        title: 'ПАКЕТ (8 КОНСУЛЬТАЦИЙ)',
        rows: [
          { label: 'Время:', value: '50 МИН × 8' },
          { label: 'Стоимость:', value: '21500 РУБЛЕЙ' },
        ],
        ctaLabel: 'ЗАПИСАТЬСЯ НА КОНСУЛЬТАЦИЮ',
      },
    ],
  },
  contacts: {
    title: 'КОНТАКТЫ',
    imageSrc: assetPath('contacts-photo-v2.png'),
    imageAlt: 'Юлия на берегу моря',
    items: [
      { label: 'WHATSAPP', href: links.whatsapp },
      { label: 'TELEGRAM', href: links.telegram },
      { label: 'VK', href: links.vk },
      { label: 'РАЗРАБОТКА САЙТА', href: links.developedBy },
    ],
  },
} as const

export type IssueTone = (typeof landingContent.issues.items)[number]['tone']
