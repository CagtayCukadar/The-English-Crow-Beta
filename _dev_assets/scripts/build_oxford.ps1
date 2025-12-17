$jsonContent = Get-Content -Raw -Path "$PSScriptRoot\..\oxford_raw.json" | ConvertFrom-Json

$sets = @{}
$levelColors = @{
    'a1' = '#4CAF50';
    'a2' = '#8BC34A';
    'b1' = '#FFC107';
    'b2' = '#FF9800';
    'c1' = '#F44336';
    'c2' = '#9C27B0'
}

# Iterate through properties
$jsonContent.PSObject.Properties | ForEach-Object {
    $entry = $_.Value
    
    # Check if entry is valid object and has required fields
    if ($entry -is [System.Management.Automation.PSCustomObject] -and $entry.word -and $entry.definition) {
        $level = "uncategorized"
        if ($entry.cefr) { $level = $entry.cefr.ToLower() }
        
        if (-not $sets.ContainsKey($level)) {
            $sets[$level] = @()
        }
        
        $def = $entry.definition
        if ($entry.example) {
            $def += " (Ex: $($entry.example))"
        }
        
        # Create card object
        $card = @{
            term = $entry.word
            def  = $def
            type = $entry.type
        }
        
        $sets[$level] += $card
    }
}

# --- MANUAL INJECTION OF C2 DATA (Oxford 5000 / American Advanced Simulation) ---
$c2Manual = @(
    @{"word"="Abysmal"; "def"="Extremely bad or severe"; "ex"="The service at the restaurant was abysmal."},
    @{"word"="Acumen"; "def"="The ability to make good judgments and quick decisions"; "ex"="She possessed a sharp business acumen."},
    @{"word"="Adamant"; "def"="Refusing to be persuaded or to change one's mind"; "ex"="He is adamant that he is not going to resign."},
    @{"word"="Admonish"; "def"="Warn or reprimand someone firmly"; "ex"="She was admonished for chewing gum in class."},
    @{"word"="Alacrity"; "def"="Brisk and cheerful readiness"; "ex"="She accepted the invitation with alacrity."},
    @{"word"="Ambivalent"; "def"="Having mixed feelings or contradictory ideas about something or someone"; "ex"="Some loved her, some hated her, few were ambivalent about her."},
    @{"word"="Ameliorate"; "def"="Make (something bad or unsatisfactory) better"; "ex"="The reform did much to ameliorate living standards."},
    @{"word"="Anachronism"; "def"="A thing belonging to a period other than that in which it exists"; "ex"="The castle was an anachronism in the modern city."},
    @{"word"="Antithesis"; "def"="A person or thing that is the direct opposite of someone or something else"; "ex"="Love is the antithesis of selfishness."},
    @{"word"="Apocryphal"; "def"="Of doubtful authenticity, although widely circulated as being true"; "ex"="An apocryphal story about the president."},
    @{"word"="Arcane"; "def"="Understood by few; mysterious or secret"; "ex"="Modern math can seem arcane to the uninitiated."},
    @{"word"="Assiduous"; "def"="Showing great care and perseverance"; "ex"="She was assiduous in pointing out every feature."},
    @{"word"="Avarice"; "def"="Extreme greed for wealth or material gain"; "ex"="He was driven by avarice."},
    @{"word"="Banality"; "def"="The fact or condition of being banal; unoriginality"; "ex"="There is an essential banality to the story."},
    @{"word"="Bellicose"; "def"="Demonstrating aggression and willingness to fight"; "ex"="A group of bellicose patriots."},
    @{"word"="Benevolent"; "def"="Well meaning and kindly"; "ex"="A benevolent smile."},
    @{"word"="Bucolic"; "def"="Relating to the pleasant aspects of the countryside"; "ex"="The church is lovely for its bucolic setting."},
    @{"word"="Cacophony"; "def"="A harsh, discordant mixture of sounds"; "ex"="A cacophony of deafening alarm bells."},
    @{"word"="Cajole"; "def"="Persuade someone to do something by sustained coaxing or flattery"; "ex"="He hoped to cajole her into selling the house."},
    @{"word"="Capitulate"; "def"="Cease to resist an opponent or an unwelcome demand"; "ex"="The patriots had to capitulate to the enemy forces."},
    @{"word"="Castigate"; "def"="Reprimand (someone) severely"; "ex"="He was castigated for not setting a good example."},
    @{"word"="Chicanery"; "def"="The use of trickery to achieve a political, financial, or legal purpose"; "ex"="An underhanded person who uses political chicanery."},
    @{"word"="Circuitous"; "def"="of a route or journey longer than the most direct way"; "ex"="The canal followed a circuitous route."},
    @{"word"="Clandestine"; "def"="Kept secret or done secretively"; "ex"="She deserved better than these clandestine meetings."},
    @{"word"="Cogent"; "def"="Typically of an argument or case: clear, logical, and convincing"; "ex"="They put forward cogent arguments for British membership."},
    @{"word"="Collusion"; "def"="Secret or illegal cooperation or conspiracy, especially in order to cheat or deceive others"; "ex"="The armed forces were working in collusion with drug traffickers."},
    @{"word"="Concomitant"; "def"="Naturally accompanying or associated"; "ex"="She loved travel, with all its concomitant worries."},
    @{"word"="Convoluted"; "def"="Extremely complex and difficult to follow"; "ex"="Its convoluted narrative encompasses all manner of digressions."},
    @{"word"="Copious"; "def"="Abundant in supply or quantity"; "ex"="She took copious notes."},
    @{"word"="Dearth"; "def"="A scarcity or lack of something"; "ex"="There is a dearth of evidence."},
    @{"word"="Debacle"; "def"="A sudden and ignominious failure; a fiasco"; "ex"="The economic debacle that became known as the Great Depression."},
    @{"word"="Deference"; "def"="Humble submission and respect"; "ex"="He addressed her with the deference due to age."},
    @{"word"="Deleterious"; "def"="Causing harm or damage"; "ex"="Divorce is assumed to have deleterious effects on children."},
    @{"word"="Demagogue"; "def"="A political leader who seeks support by appealing to the desires and prejudices of ordinary people"; "ex"="A gifted demagogue with particular skill in manipulating the press."},
    @{"word"="Desultory"; "def"="Lacking a plan, purpose, or enthusiasm"; "ex"="A few people were left, dancing in a desultory fashion."},
    @{"word"="Diatribe"; "def"="A forceful and bitter verbal attack against someone or something"; "ex"="A diatribe against the Roman Catholic Church."},
    @{"word"="Didactic"; "def"="Intended to teach, particularly in having moral instruction as an ulterior motive"; "ex"="A didactic novel that set out to expose social injustice."},
    @{"word"="Diffident"; "def"="Modest or shy because of a lack of self-confidence"; "ex"="A diffident youth."},
    @{"word"="Disparate"; "def"="Essentially different in kind; not allowing comparison"; "ex"="They inhabit disparate worlds of thought."},
    @{"word"="Ebullient"; "def"="Cheerful and full of energy"; "ex"="She sounded ebullient and happy."},
    @{"word"="Egregious"; "def"="Outstandingly bad; shocking"; "ex"="Egregious abuses of copyright."},
    @{"word"="Eloquent"; "def"="Fluent or persuasive in speaking or writing"; "ex"="An eloquent speech."},
    @{"word"="Enervate"; "def"="Cause (someone) to feel drained of energy or vitality; weaken"; "ex"="The heat enervated us all."},
    @{"word"="Ephemeral"; "def"="Lasting for a very short time"; "ex"="Fashions are ephemeral, changing with every season."},
    @{"word"="Equanimity"; "def"="Mental calmness, composure, and evenness of temper, especially in a difficult situation"; "ex"="She accepted both the good and the bad with equanimity."},
    @{"word"="Esoteric"; "def"="Intended for or likely to be understood by only a small number of people with a specialized knowledge"; "ex"="Esoteric philosophical debates."},
    @{"word"="Evanescent"; "def"="Soon passing out of sight, memory, or existence; quickly fading or disappearing"; "ex"="A shimmering evanescent bubble."},
    @{"word"="Exacerbate"; "def"="Make (a problem, bad situation, or negative feeling) worse"; "ex"="The exorbitant cost of land in urban areas only exacerbated the problem."},
    @{"word"="Exonerate"; "def"="Absolve (someone) from blame for a fault or wrongdoing"; "ex"="The inquiry exonerated the driver from any blame."},
    @{"word"="Extrapolate"; "def"="Extend the application of (a method or conclusion, especially one based on statistics) to an unknown situation by assuming that existing trends will continue"; "ex"="The results cannot be extrapolated to other patient groups."},
    @{"word"="Facetious"; "def"="Treating serious issues with deliberately inappropriate humor"; "ex"="Unfortunately, they took my facetious remarks seriously."},
    @{"word"="Fastidious"; "def"="Very attentive to and concerned about accuracy and detail"; "ex"="He chooses his words with fastidious care."},
    @{"word"="Furtive"; "def"="Attempting to avoid notice or attention, typically because of guilt or a belief that discovery would lead to trouble"; "ex"="They spent a furtive day together."},
    @{"word"="Garrulous"; "def"="Excessively talkative, especially on trivial matters"; "ex"="Polonius is portrayed as a foolish, garrulous old man."},
    @{"word"="Gregarious"; "def"="(of a person) fond of company; sociable"; "ex"="He was a popular and gregarious man."},
    @{"word"="Hackneyed"; "def"="(of a phrase or idea) lacking significance through having been overused; unoriginal and trite"; "ex"="Hackneyed old sayings."},
    @{"word"="Harangue"; "def"="A lengthy and aggressive speech"; "ex"="He delivered a violent harangue to the troops."},
    @{"word"="Hedonist"; "def"="A person who believes that the pursuit of pleasure is the most important thing in life"; "ex"="She was living the life of a committed hedonist."},
    @{"word"="Iconoclast"; "def"="A person who attacks cherished beliefs or institutions"; "ex"="An iconoclast who refused to accept the established dogmas."},
    @{"word"="Idiosyncratic"; "def"="Relating to idiocrasy; peculiar or individual"; "ex"="She emerged as one of the great idiosyncratic talents of the Nineties."},
    @{"word"="Impede"; "def"="Delay or prevent (someone or something) by obstructing them; hinder"; "ex"="The sap causes swelling that impedes breathing."},
    @{"word"="Impetuous"; "def"="Acting or done quickly and without thought or care"; "ex"="Her friend was headstrong and impetuous."},
    @{"word"="Implacable"; "def"="Unable to be placated"; "ex"="He was an implacable enemy of Ted's."},
    @{"word"="Impunity"; "def"="Exemption from punishment or freedom from the injurious consequences of an action"; "ex"="The impunity enjoyed by military officers implicated in human rights abuses."},
    @{"word"="Inchoate"; "def"="Just begun and so not fully formed or developed; rudimentary"; "ex"="A still inchoate democracy."},
    @{"word"="Indefatigable"; "def"="(of a person or their efforts) persisting tirelessly"; "ex"="An indefatigable defender of human rights."},
    @{"word"="Indolent"; "def"="Wanting to avoid activity or exertion; lazy"; "ex"="They were indolent and addicted to a life of pleasure."},
    @{"word"="Ineffable"; "def"="Too great or extreme to be expressed or described in words"; "ex"="The ineffable natural beauty of the Everglades."},
    @{"word"="Ingenuous"; "def"="(of a person or action) innocent and unsuspecting"; "ex"="He eyed her with wide, ingenuous eyes."},
    @{"word"="Inimical"; "def"="Tending to obstruct or harm"; "ex"="Actions inimical to our interests."},
    @{"word"="Innocuous"; "def"="Not harmful or offensive"; "ex"="It was an innocuous question."},
    @{"word"="Insidious"; "def"="Proceeding in a gradual, subtle way, but with harmful effects"; "ex"="Sexually transmitted diseases can be insidious and sometimes without symptoms."},
    @{"word"="Intransigent"; "def"="Unwilling or refusing to change one's views or to agree about something"; "ex"="Her father had tried persuasion, but she was intransigent."},
    @{"word"="Inveterate"; "def"="Having a particular habit, activity, or interest that is long-established and unlikely to change"; "ex"="He was an inveterate gambler."},
    @{"word"="Juxtaposition"; "def"="The fact of two things being seen or placed close together with contrasting effect"; "ex"="The juxtaposition of these two images."},
    @{"word"="Laconical"; "def"="(of a person, speech, or style of writing) using very few words"; "ex"="His laconic reply suggested a lack of interest."},
    @{"word"="Languid"; "def"="(of a person, manner, or gesture) displaying or having a disinclination for physical exertion or effort; slow and relaxed"; "ex"="They turned with languid movements from back to front."},
    @{"word"="Largess"; "def"="Generosity in bestowing money or gifts upon others"; "ex"="Dispensing his money with such largesse."},
    @{"word"="Latent"; "def"="(of a quality or state) existing but not yet developed or manifest; hidden; concealed"; "ex"="Discovering her latent talent for diplomacy."},
    @{"word"="Loquacious"; "def"="Tending to talk a great deal; talkative"; "ex"="Never loquacious, Sarah was now totally lost for words."},
    @{"word"="Lucid"; "def"="Expressed clearly; easy to understand"; "ex"="A lucid account of the history of civilization."},
    @{"word"="Magnanimous"; "def"="Generous or forgiving, especially toward a rival or less powerful person"; "ex"="She should be magnanimous in victory."},
    @{"word"="Malaise"; "def"="A general feeling of discomfort, illness, or uneasiness whose exact cause is difficult to identify"; "ex"="A society afflicted by a deep cultural malaise."},
    @{"word"="Malleable"; "def"="(of a metal or other material) able to be hammered or pressed permanently out of shape without breaking or cracking"; "ex"="Anna was shaken enough to be malleable."},
    @{"word"="Maverick"; "def"="A person who thinks and acts in an independent way, often behaving differently from the expected or usual way"; "ex"="A maverick detective."},
    @{"word"="Mendacious"; "def"="Not telling the truth; lying"; "ex"="Mendacious propaganda."},
    @{"word"="Mercurial"; "def"="(of a person) subject to sudden or unpredictable changes of mood or mind"; "ex"="His mercurial temperament."},
    @{"word"="Mitigate"; "def"="Make less severe, serious, or painful"; "ex"="He wanted to mitigate misery in the world."},
    @{"word"="Mollify"; "def"="Appease the anger or anxiety of (someone)"; "ex"="Nature reserves were set up around the power stations to mollify local conservationists."},
    @{"word"="Morose"; "def"="Sullen and ill-tempered"; "ex"="She was morose and silent when she got home."},
    @{"word"="Munificent"; "def"="(of a gift or sum of money) larger or more generous than is usual or necessary"; "ex"="A munificent bequest."},
    @{"word"="Myriad"; "def"="A countless or extremely great number"; "ex"="Networks connecting a myriad of computers."},
    @{"word"="Nefarious"; "def"="(typically of an action or activity) wicked or criminal"; "ex"="The nefarious activities of the organized-crime syndicates."},
    @{"word"="Obfuscate"; "def"="Render obscure, unclear, or unintelligible"; "ex"="The spelling changes will deform some familiar words and obfuscate their etymological origins."},
    @{"word"="Obsequious"; "def"="Obedient or attentive to an excessive or servile degree"; "ex"="They were served by obsequious waiters."},
    @{"word"="Obtuse"; "def"="Annoyingly insensitive or slow to understand"; "ex"="He wondered if the doctor was being deliberately obtuse."},
    @{"word"="Obviate"; "def"="Remove (a need or difficulty)"; "ex"="The Venetian blinds obviated the need for curtains."},
    @{"word"="Onerous"; "def"="(of a task, duty, or responsibility) involving an amount of effort and difficulty that is oppressively burdensome"; "ex"="He found his duties increasingly onerous."},
    @{"word"="Ostentatious"; "def"="Characterized by vulgar or pretentious display; designed to impress or attract notice"; "ex"="Books that people buy and display ostentatiously but never actually finish."},
    @{"word"="Paragon"; "def"="A person or thing regarded as a perfect example of a particular quality"; "ex"="It would have taken a paragon of virtue not to feel viciously jealous."},
    @{"word"="Pariah"; "def"="An outcast"; "ex"="They were treated as social pariahs."},
    @{"word"="Parsimony"; "def"="Extreme unwillingness to spend money or use resources"; "ex"="A great tradition of public design has been shattered by government parsimony."},
    @{"word"="Paucity"; "def"="The presence of something only in small or insufficient quantities or amounts; scarcity"; "ex"="A paucity of information."},
    @{"word"="Pedantic"; "def"="Of or like a pedant"; "ex"="Many of the essays are long, dense, and pedantic."},
    @{"word"="Perfunctory"; "def"="(of an action or gesture) carried out with a minimum of effort or reflection"; "ex"="He gave a perfunctory nod."},
    @{"word"="Pernicious"; "def"="Having a harmful effect, especially in a gradual or subtle way"; "ex"="The pernicious influences of the mass media."},
    @{"word"="Perspicacity"; "def"="The quality of having a ready insight into things; shrewdness"; "ex"="The perspicacity of her remarks."},
    @{"word"="Pervasive"; "def"="(especially of an unwelcome influence or physical effect) spreading widely throughout an area or a group of people"; "ex"="Ageism is pervasive and entrenched in our society."},
    @{"word"="Placate"; "def"="Make (someone) less angry or hostile"; "ex"="They attempted to placate the students with promises."},
    @{"word"="Plethora"; "def"="A large or excessive amount of (something)"; "ex"="A plethora of committees and subcommittees."},
    @{"word"="Polemic"; "def"="A strong verbal or written attack on someone or something"; "ex"="His polemic against the cultural relativism of the Sixties."},
    @{"word"="Pragmatic"; "def"="Dealing with things sensibly and realistically in a way that is based on practical rather than theoretical considerations"; "ex"="A pragmatic approach to politics."},
    @{"word"="Precipitous"; "def"="Dangerously high or steep"; "ex"="The precipitous cliffs of the North Atlantic coast."},
    @{"word"="Prevaricate"; "def"="Speak or act in an evasive way"; "ex"="He seemed to prevaricate when journalists asked pointed questions."},
    @{"word"="Probity"; "def"="The quality of having strong moral principles; honesty and decency"; "ex"="Financial probity."},
    @{"word"="Proclivity"; "def"="A tendency to choose or do something regularly; an inclination or predisposition toward a particular thing"; "ex"="A proclivity for hard work."},
    @{"word"="Profligate"; "def"="Recklessly extravagant or wasteful in the use of resources"; "ex"="Profligate consumers of energy."},
    @{"word"="Prolific"; "def"="(of a plant, animal, or person) producing much fruit or foliage or many offspring"; "ex"="In captivity, tigers are prolific breeders."},
    @{"word"="Propensity"; "def"="An inclination or natural tendency to behave in a particular way"; "ex"="A propensity for violence."},
    @{"word"="Prosaic"; "def"="Having the style or diction of prose; lacking poetic beauty"; "ex"="Prosaic language can't convey the experience."},
    @{"word"="Prudent"; "def"="Acting with or showing care and thought for the future"; "ex"="No prudent money manager would authorize a loan without knowing the borrower's purpose."},
    @{"word"="Pugnacious"; "def"="Eager or quick to argue, quarrel, or fight"; "ex"="His public statements became increasingly pugnacious."},
    @{"word"="Quixotic"; "def"="Exceedingly idealistic; unrealistic and impractical"; "ex"="A vast and perhaps quixotic project."},
    @{"word"="Rancorous"; "def"="Characterized by bitterness or resentment"; "ex"="Sixteen miserable months of rancorous disputes."},
    @{"word"="Recalcitrant"; "def"="Having an obstinately uncooperative attitude toward authority or discipline"; "ex"="A class of recalcitrant fifteen-year-olds."},
    @{"word"="Recondite"; "def"="(of a subject or knowledge) little known; abstruse"; "ex"="The book is full of recondite information."},
    @{"word"="Redolent"; "def"="Strongly reminiscent or suggestive of (something)"; "ex"="Names redolent of history and tradition."},
    @{"word"="Replete"; "def"="Filled or well-supplied with something"; "ex"="Sensational popular fiction, replete with adultery and sudden death."},
    @{"word"="Rescind"; "def"="Revoke, cancel, or repeal (a law, order, or agreement)"; "ex"="The government eventually rescinded the directive."},
    @{"word"="Reticent"; "def"="Not revealing one's thoughts or feelings readily"; "ex"="She was extremely reticent about her personal affairs."},
    @{"word"="Reverent"; "def"="Feeling or showing deep and solemn respect"; "ex"="A reverent silence."},
    @{"word"="Sagacity"; "def"="The quality of being sagacious"; "ex"="A man of great political sagacity."},
    @{"word"="Salient"; "def"="Most noticeable or important"; "ex"="It succinctly covered all the salient points of the case."},
    @{"word"="Sanctimonious"; "def"="Making a show of being morally superior to other people"; "ex"="What happened to all the sanctimonious talk about putting music first?"},
    @{"word"="Sanguine"; "def"="Optimistic or positive, especially in an apparently bad or difficult situation"; "ex"="He is sanguine about prospects for the global economy."},
    @{"word"="Scrutinize"; "def"="Examine or inspect closely and thoroughly"; "ex"="Customers were warned to scrutinize the small print."},
    @{"word"="Serendipity"; "def"="The occurrence and development of events by chance in a happy or beneficial way"; "ex"="A fortunate stroke of serendipity."},
    @{"word"="Solicitous"; "def"="Characterized by or showing interest or concern"; "ex"="She was always solicitous about the welfare of her students."},
    @{"word"="Soporific"; "def"="Tending to induce drowsiness or sleep"; "ex"="The motion of the train had a somewhat soporific effect."},
    @{"word"="Specious"; "def"="Superficially plausible, but actually wrong"; "ex"="A specious argument."},
    @{"word"="Spurious"; "def"="Not being what it purports to be; false or fake"; "ex"="Separating authentic and spurious claims."},
    @{"word"="Stoic"; "def"="A person who can endure pain or hardship without showing their feelings or complaining"; "ex"="He was stoic in the face of adversity."},
    @{"word"="Sublime"; "def"="Of such excellence, grandeur, or beauty as to inspire great admiration or awe"; "ex"="Mozart's sublime piano concertos."},
    @{"word"="Superfluous"; "def"="Unnecessary, especially through being more than enough"; "ex"="The purchaser should avoid asking for superfluous information."},
    @{"word"="Surreptitious"; "def"="Kept secret, especially because it would not be approved of"; "ex"="They carried on a surreptitious affair."},
    @{"word"="Sycophant"; "def"="A person who acts obsequiously toward someone important in order to gain advantage"; "ex"="He was surrounded by sycophants."},
    @{"word"="Taciturn"; "def"="(of a person) reserved or uncommunicative in speech; saying little"; "ex"="After such gatherings she would be taciturn and morose."},
    @{"word"="Tantalize"; "def"="Torment or tease (someone) with the sight or promise of something that is unobtainable"; "ex"="Ambitious questions that tantalize the world's best thinkers."},
    @{"word"="Temerity"; "def"="Excessive confidence or boldness; audacity"; "ex"="No one had the temerity to question his conclusions."},
    @{"word"="Tenuous"; "def"="Very weak or slight"; "ex"="The tenuous link between interest rates and investment."},
    @{"word"="Timorous"; "def"="Showing or suffering from nervousness, fear, or a lack of confidence"; "ex"="A timorous voice."},
    @{"word"="Tirade"; "def"="A long, angry speech of criticism or accusation"; "ex"="A tirade of abuse."},
    @{"word"="Torpor"; "def"="A state of physical or mental inactivity; lethargy"; "ex"="They veered between apathetic torpor and hysterical fanaticism."},
    @{"word"="Transient"; "def"="Lasting using for a short time; impermanent"; "ex"="A transient cold spell."},
    @{"word"="Trepidation"; "def"="A feeling of fear or agitation about something that may happen"; "ex"="The men set off in fear and trepidation."},
    @{"word"="Ubiquitous"; "def"="Present, appearing, or found everywhere"; "ex"="His ubiquitous influence was felt by all the family."},
    @{"word"="Vacillate"; "def"="Alternate or waver between different opinions or actions; be indecisive"; "ex"="I had for a time vacillated between teaching and journalism."},
    @{"word"="Venerable"; "def"="Accorded a great deal of respect, especially because of age, wisdom, or character"; "ex"="A venerable statesman."},
    @{"word"="Veracity"; "def"="Conformity to facts; accuracy"; "ex"="Officials expressed doubts concerning the veracity of the story."},
    @{"word"="Verbose"; "def"="Using or expressed in more words than are needed"; "ex"="Much academic language is obscure and verbose."},
    @{"word"="Vex"; "def"="Make (someone) feel annoyed, frustrated, or worried, especially with trivial matters"; "ex"="The memory of the conversation still vexed him."},
    @{"word"="Vindicate"; "def"="Clear (someone) of blame or suspicion"; "ex"="Hospital staff were vindicated by the inquest verdict."},
    @{"word"="Virulent"; "def"="(of a disease or poison) extremely severe or harmful in its effects"; "ex"="A virulent strain of influenza."},
    @{"word"="Visceral"; "def"="Relating to deep inward feelings rather than to the intellect"; "ex"="The voters' visceral fear of change."},
    @{"word"="Vituperate"; "def"="Blame or insult (someone) in strong or violent language"; "ex"="The press vituperated the new president."},
    @{"word"="Vociferous"; "def"="(especially of a person or speech) vehement or clamorous"; "ex"="He was a vociferous opponent of the takeover."},
    @{"word"="Volatile"; "def"="(of a substance) easily evaporated at normal temperatures"; "ex"="Volatile solvents such as petroleum ether."},
    @{"word"="Zealot"; "def"="A person who is fanatical and uncompromising in pursuit of their religious, political, or other ideals"; "ex"="One of the zealots who organized the hunger strike."}
)

if (-not $sets.ContainsKey('c2')) { $sets['c2'] = @() }

foreach ($item in $c2Manual) {
    if ($item.ex) { $def = "$($item.def) (Ex: $($item.ex))" } 
    else { $def = $item.def }
    
    $sets['c2'] += @{
        term = $item.word
        def  = $def
        type = "noun/adj" 
    }
}
# ------------------------------------------------------------------

$output = @()
$levels = @('a1', 'a2', 'b1', 'b2', 'c1', 'c2')

foreach ($lvl in $levels) {
    if ($sets.ContainsKey($lvl)) {
        $color = '#999'
        if ($levelColors.ContainsKey($lvl)) { $color = $levelColors[$lvl] }
        
        $setObj = @{
            id         = $lvl.ToUpper()
            title      = "Oxford 3000/5000 - $($lvl.ToUpper())"
            desc       = "Essential vocabulary for level $($lvl.ToUpper())"
            thumbColor = $color
            cards      = $sets[$lvl]
        }
        $output += $setObj
    }
}

# Convert to JSON with depth to preserve objects
$jsonOutput = $output | ConvertTo-Json -Depth 5

$jsContent = "window.OXFORD_DATA = $jsonOutput;"
$outPath = Join-Path "$PSScriptRoot\.." "js\oxford.js"

Set-Content -Path $outPath -Value $jsContent -Encoding UTF8

Write-Host "Processed levels: $($output.Count)"
foreach ($s in $output) {
    Write-Host "$($s.id): $($s.cards.Count) words"
}
