= systems view on election systems

// progression:
//
// - raising hands (athens)
// - anonymous ballots (rome)
// - more stuff about ballots
// - ballot security, transport
// - chain of custody protocols
// - protocols for public counting

// - hands
// - ballots
// - delegated representation
// - chain of custody and public counting
// - ballot security

// then into misc stuff
//
// - mail in ballot protection

== raising hands?

// morning sun, its uneven stones whispering echoes of those who had climbed them
// in frustration and hope. cleisthenes stood there, watching the agora below,
// where merchants and farmers argued over weights of grain, and philosophers spun
// thoughts into webs that only they seemed to understand. the city was restless,
// like the sea against the long walls, ready to churn but unsure of its
// direction.
//
// "too many kings," cleisthenes muttered to himself, "too many tyrants." he ran a
// calloused hand over his brow. his family, the alcmaeonids, had known the weight
// of power, the allure of it. but cleisthenes had seen what it did—turning men
// into wolves, and the polis into prey. he had no interest in ruling over wolves.
// instead, he dreamed of something impossible: a city ruled by its citizens.
//
// that night, he convened with the elders. the flickering lamplight played
// shadows on their faces, as if they themselves were caught between light and
// dark, between old ways and a new, untrodden path.
//
// “cleisthenes,” one said, his voice gruff and impatient. “what is this madness?
// you would give the reins of power to fishermen? to potters?”
//
// “yes,” cleisthenes replied, steady. “and to you. and to me. to all of us.”
//
// his proposal was simple but radical: dismantle the tribal lines that had
// divided athens for generations. no longer would men be bound to their family’s
// honor or their father’s feuds. in their place, ten tribes—new tribes—drawn by
// lot, mixed from the mountains, the coast, and the plains. every man, an equal
// voice in the assembly. decisions made by debate, not decree.
//
// the elders roared in protest. “madness! chaos!” but cleisthenes stood firm. he
// knew that beneath their resistance was fear—fear of losing control, fear of
// what might happen when the voices of the many drowned out the whispers of the
// few.
//
// change did not come easily. the years ahead saw riots, betrayals, and moments
// when cleisthenes himself doubted. but the people came to the pnyx, day after
// day, each one finding his voice. they debated the cost of war, the price of
// grain, the punishment of thieves. they argued over everything, and in their
// arguing, they built a new kind of polis—a city governed not by the whims of one
// man, but by the collective will of its citizens.

// do some creative non-fiction based off of
// https://en.wikipedia.org/wiki/Athenian_democracy
// https://en.wikipedia.org/wiki/Cleisthenes

the protocol is simple. we hold an _ecclesia_, or assembly, where an open debate
is held to discuss the options. everyone raises their hand for each option.
then, we just use our eyes and look at the audience. for overwhelming
majorities, the choice easily stands out. a few officials, presumably not
colluding, can declare the winner.

- *transparent*: everyone in the room can look at the audience and see that everyone
  agrees. more importantly, everyone can visually audit and trust the result.

now, i walk into the room with an ar-15 rifle and declare: "anyone who votes
for the wrong option gets shot." obviously, we've overlooked some issues. this
can be due to explicit threats, but also more subtle forms of coercion such as
groupthink, peer pressure, or generally a fear of being contrarian. anonymity
is necessary for the the vote to correctly model the consensus belief.

- *precise*: we don't have an accurate count. the majority is based on an estimate.
- *anonymous*: everyone knows which option everyone else picked. clearly, this is a problem.

== anonymity with ballots

// https://en.wikipedia.org/wiki/Ballot_laws_of_the_Roman_Republic
// TODO: sybil attack might be an incorrect term.

// TODO: missing attack vectors: ballot box swapping

// mention dprk, why the elections are so skewed lol

instead of just raising our hands, we can use ballots. we'll pass around
_tabellae_, wax-coated wooden tablets, on which the vote is inscribed. the
tablets are placed in a _cista_, or ballot box, for which there is a public
counting that takes place.

we've got

- *transparent*: the process is easy to audit and understand.
- *precise*: we get an exact count at the end.
- *anonymous*: we can't see who voted for what.

// TODO: we need to forbit ballot marking
// TODO: "transparent" is a better term than trustless
// TODO: a ballot can be pre-stuffed, though the count will be innacurate
//
// TODO: chain voting:
// A voter is handed a pre-filled ballot by the buyer and instructed to cast it. Afterward, the voter brings back their original blank ballot to the buyer as proof, perpetuating the cycle.
//
// TODO: need voting booths to be private

// TODO: alternatives to decentralization:
//
// - "distributed accessibility" or accessible voting
// - "scalable participation" or scalable
// - "operational independence" or maybe just "available"

notice now, we've introduced a new vulnerability due to the anonymity: multiple
votes per person, or sybil attacks! however, we've got a new flaw to address:

- *sybil-resistant*: how do we prevent multiple votes per person, i.e. ballot
  stuffing?

the solution at a small scale is simple. we can hold physical assemblies, what
are called _comitia_. voting requires registration, and the voting process is
done in a public room with the counting done by a few trusted magistrates. and
we can also use roll-call voting, where everyone is called on to insert their
ballot or ensure that each person only gets one tabella. there's a few other
constraints we'd like to enforce, given that the empire is growing:

- *accessible*: 

// more attacks:
// - impersonation
// - denial of service, ie disrupting the voting process
//
// TODO: voter registration helps here?

// Only eligible citizens could physically participate, and they had to be present to vote. This physical presence requirement inherently made sybil attacks much harder compared to systems with remote or proxy voting.
//
// Citizen Rolls: Each citizen was registered in official rolls maintained by censors. These rolls identified eligible voters and linked them to their assigned voting unit (centuria or tribus).
// Lictors and Officials: At the entrance to the voting area, officials verified eligibility based on these rolls. This acted as an early form of identity verification.
// Strict Quorum Rules: Many assemblies required a certain number of voters or representatives from each group to proceed, which added an implicit layer of validation against manipulation.


// some issues:
// - "permissionlessness" or "accessibility": not anyone can sign up in this system. we need to
// - "efficiency": or parallelizability? centralization, non-concurrent voting, and slow counting
//
// actually maybe call that "decentralization", because you also have issues like participability
// idk how to split these two issues they're not distinct enough. decentralization enables faster
// counting, paralellization, and accessibility.


// https://en.wikipedia.org/wiki/Pr%C3%AAt_%C3%A0_Voter

// Examples of Paper Voting at Scale
//
// India:
//     World’s largest democracy with over 900 million eligible voters.
//     Uses electronic voting machines but relies on manual processes for tallying and auditing in remote areas.
// United States:
//     Many states use paper ballots, often combined with optical scanning for fast counting.
//     Risk-limiting audits provide additional verification.
// Germany:
//     Entirely paper-based elections with centralized counting and strict chain-of-custody protocols.
//
// Risk-Limiting Audits (RLA):
// Statistical audits confirm the accuracy of election outcomes, ensuring
// integrity without needing to recount every vote.
//
// delegated representation as opposed to direct representation
// (see the textbook that aili shared)

// TODO: not sure if worth covering. does address scalability, but should not be
// needed for the analysis.
//
// == delegated representation
// 
// so far, voting has directly represented the will of the people. however,
// as the empire grows, we can't scale having everyone vote at the assembly.
// instead, we'll do _delegation_. the country is divided into 

== secret (paper) ballots

in practice, we use paper ballots. the ballots are pre-filled with the
candidates' names and voters check off their choice. this is similar to the
previous system, but now we want to expand it to a vast geographical area.
even with delegated representation, where locales vote for a representative
for their area, we still need to be able to scale elections to the district.
so, we'll write down our new requirements:

- *scalable*: the process can be scaled up to the order of millions of voters.
- *accessible*: anyone eligible to vote can, with little effort, cast their vote.

notice that neither of these requirements are satisfied by the previous system.
assemblies require collecting all voters together, which makes them neither
accessible nor scalable. however, the centralization was crucial to the
sybil-resistance. how do we provide sybil-resistance with anonymity? the case
study we'll be looking at here is the german election system, since it is still
based completely on paper ballots.

given that voters vote on ballots, the process is simple:

+ give each voter a ballot
+ each voter checks off their choice
+ ballots are counted

so, it suffices to find a way to distribute the process of signing, collecting,
and counting. allowing voters to vote from many geographic provides
accessibility, and constructing a way to count across a vast geographic area
solves scalability.

// TODO: figure here

suppose we have several geographically distributed locations for voting. first,
how do we prevent sybil attacks? even with id verification, it's possible for
someone to vote at multiple locations by quickly moving between them. voter
impersonation is also easy to do without an unforgeable identifier or if
#link("https://en.wikipedia.org/wiki/Proxy_voting", "proxy voting") is
permitted.

we'll start with several geographic locations. we assume each eligible voter
has an unambiguous id using their national id card and that this card is
unforgeable. to prevent sybils, we assign the voting location during
registration. the voter is only able to vote at their assigned location.

we now have a simple heuristic we can use to limit sybils. assuming that voting
sites are behaving to protocol, each vote requires burning a registered person
on the list. thus, the only way to sybil is through impersonation, which
requires forging id cards. of course, we've moved the problem, and a
sufficiently sophisticated attacker can still impersonate them, but the impact
and likelihood are severely reduced.

assumptions:

- voting sites behave to protocol
- identifiers are unforgeable

now, the protocol for the voter is as follows:

+ after verification at the site, which can only be done once, the voter is given one ballot
+ the voter goes in a booth to privately check off their choice
+ the ballot is folded to hide when moving
+ the ballot is put in a box in view of election officials

now, there's some issues that crop up.

- how do we ensure that the election site is behaving? the employees can collude
- where and how are the ballots stored, transported, and counted to prevent tampering?

// TODO: discuss forging id cards
// TODO: pre and post election audits

== chain of custody protocols

we now get to ballot transport and tamper-resistance.

== pre- and post-election audits

// TODO

== "minimal surface needed to modify the election"

// https://www.theguardian.com/us-news/ng-interactive/2024/sep/03/electoral-votes-swing-state-margins-explained
// ie we are still somewhat vulnerable to attacking election sites.
// i should really document what the protections here are.


// ballot tracking? https://www.youtube.com/watch?v=u8qq_Bx0woc

== mail-in ballots

// ballot box destruction? https://www.youtube.com/watch?v=b0bI431YDqQ
// how do they know who put the ballot in the box tf?
// seems that this is required to be able to recover the ballot and avoid double-counting
// seems to be called "ballot curing"
