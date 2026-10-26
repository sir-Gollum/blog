+++
date = '2026-10-26T16:15:00+01:00'
draft = false
title = 'My current bag of agentic tricks'
tags = ['tools', 'ai']
type = "posts"
+++

Like a lot of people these days, I use [Claude Code](https://claude.com/product/claude-code) and [Cursor](https://cursor.com/) quite a bit at work - for writing code, reviewing PRs, and digging into all sorts of problems. At some point I had so many agent sessions going that I became the main bottleneck: the agents do their thing, then sit around waiting for me to get to them.

Here's how I've set things up to make that more manageable. My approach keeps evolving, so at some point there might be enough new ideas for an update.

<!--more-->

### Bottleneck

I quickly found that keeping track of more than [5-7 sessions at once](https://en.wikipedia.org/wiki/The_Magical_Number_Seven,_Plus_or_Minus_Two) is difficult. One needs an answer, another has a result to look at, a third wants approval for the next step. With complex tasks, by the time I've worked through one, I've forgotten what was happening in the others: why we were doing this, what we'd agreed on, and why the agent is even digging in that direction.

I can always start more agents, but that only makes the queue for my attention longer. I needed to make things a bit easier for myself: less re-reading conversations, and less time figuring out what agents want from me.

The simplest trick to start with is to talk to agents in the language you read fastest. For me, that's Russian. I have no issues reading English, but skimming text and picking out the important bits is still a little faster in my native language. It doesn't save much on a single message, but it accumulates as I keep coming back to tasks throughout the day.

### A Terminal Built for Agents

For a month or two, I used [Herdr](https://herdr.dev/) to organize my sessions - a terminal multiplexer similar to tmux, but with little status icons for agents. About 3-4 weeks ago I switched to [Agterm](https://agterm.com/) by Umputun from [Radio-T](https://radio-t.com/), and that significantly improved my workflow.

Agterm is an opinionated, macOS-native terminal built on [Ghostty](https://ghostty.org/). It integrates with different agent harnesses and shows the same agent status icons as Herdr. But for the setup I describe below, another of its features matters much more - one that's both very simple and very powerful.

Agterm has a CLI that lets you list sessions, read the contents of windows and split panes, send messages to them, and create new sessions. This lets an agent to fully control the terminal and the other agents running inside it.

The terminal comes with skills that teach agents how to work with it. With those skills, I let the agent handle all the configuration too - I hadn't used Ghostty before, so I didn't even try to learn how to configure it. I just described what I wanted in Claude Code and got pretty much that. For example, Agterm didn't restore agent sessions out of the box - something I missed after switching from Herdr. I asked Claude Code to set up similar behavior and got what I wanted after a few iterations. That way I can keep tweaking the terminal to suit me without waiting for the author to add a specific feature - as long as there are enough hooks to build on.

### The Boss's Boss

The next step was to separate coordinating agents from making decisions that actually need my attention. Another agent can collect replies from several sessions, summarize them, and pass my clarifications to the workers.

I started a separate Claude Code session and made it the coordinator. It uses Agterm CLI to manage the other sessions: assign tasks, read replies, collect results, and keep track of who's doing what. I mostly talk to the coordinator these days.

I ended up with a small virtual office where I'm the boss's boss :)

Instead of several walls of text, the coordinator gives me a short summary of the current situation: what's done, where there are problems, which sessions need a decision from me, and what their questions are. I reply, and it turns my answer into a detailed prompt for the worker, sends it to the right session, and comes back with the result a little later. The prompts it writes are quite nice to look at too: detailed, structured, and several paragraphs long where I'd have written a couple of lines.

The workers aren't hidden away. If the summary isn't enough for me, I can jump into a particular terminal session, read the full conversation, and message the agent directly if I want to. It is a skip-level of sorts: I usually go through the manager, but nothing stops me from chatting with a worker directly. The summary is usually enough, but sometimes it's easier to open the full conversation and figure things out myself.

### Feedback Loop

Since each task lives in its own session, context and useful discoveries can get lost when it closes. The next agent then has to figure out how the project works all over again, or gets stuck on the same things the previous one struggled with. To carry that experience between sessions, I borrowed two things from regular team workflows: writing retro docs after a task and periodically going through them to improve the process.

Before closing a worker session, the coordinator asks the agent to do a small postmortem: where it got stuck or went off track, what it wasted turns on, what information it was missing, and what would help the next session avoid the same mistakes. The agent commits the result to a separate local repo.

About once a week, the coordinator and I go mining through the retro docs. It reads the accumulated reviews, combines recurring points, and suggests what to do with them. Some findings belong in `CLAUDE.md`, others call for a new or updated skill, and some go into memory. Others can just be dropped because they're too niche and unlikely to come up again, but would still take up context. Besides adding new things, Claude also looks at what can be cleaned up: old rules, outdated memories, and duplicate or no-longer-needed instructions in `CLAUDE.md`.

What comes out of this is useful knowledge about projects, infrastructure, and our internal processes that was never written down anywhere - basically tribal knowledge. After 3-4 weeks, I get the impression that this feedback loop really works: the agents get stuck and confused less often, I don't have to explain things again as much, and I don't need to try to write the perfect detailed `CLAUDE.md` upfront.

For example, a colleague and I were recently troubleshooting a problem with our application in k8s. With just a couple of words, the agent figured out which cluster / namespace to go to and exactly what to look at there. My colleague was pretty impressed, and it was nice to see that the accumulated knowledge was actually useful :)

### A Decision Dashboard

Once I had more than ten sessions, I ran into the next limitation. The coordinator tells me I need to choose option A, B, or C for an ongoing task, and I no longer remember what the task is or why there's a choice to make - especially since my original instruction was something like "have a look at ticket ABCD-123".

I asked it to build an HTML dashboard listing the open sessions and everything waiting for my attention. For each task, it also generates a separate page with the full context: what the task is even about, an analysis of the situation, what's been done, what decisions we've made, and what exactly it needs from me. Where relevant, it also includes messages written in my style, ready to copy into Slack or Jira.

Recent versions of Agterm can display HTML right inside the terminal, so I now have the coordinator in the left pane and its dashboard in the right. The dashboard and question pages have input fields and choices. The coordinator gets my answers and comments in a single message, grouped by task. I can just work through the questions right there on the page, with all the context in front of me - no jumping between sessions or copying text back and forth.

### Pair Programming

My latest experiment is pair programming between agents. For this, I taught the coordinator to prompt not just Claude Code but also Cursor, which has models from different vendors, including OpenAI and Google. Using different vendors is key here, because Sonnet and Opus are trained in roughly the same way on roughly the same data. I want the models to catch each other's mistakes rather than repeat the same ones.

For a sufficiently complex task, the coordinator starts two sessions in the same window, in neighboring panes: Claude Code and Cursor with the selected model. Both get the task and first agree on who will implement it and who will review it. When the implementer finishes a step and commits the changes, the reviewer immediately looks at the commit, runs tests, and gives feedback. The implementer fixes the issues, and they move on to the next step.

The idea is to catch mistakes and unnecessary complexity along the way, before the agent has built everything else on top of them. Reworking one step is easier than untangling the implementation later.

We still run a review through revmux at the end - more on it below. With this approach, revmux finds fewer things to fix, since some of the problems have already been caught and dealt with along the way. It's still subjective, but so far it feels like there are fewer bugs and less unnecessary complexity.

I put this pair-programming workflow together with Claude Code in about half an hour to an hour - explained what I wanted and iterated a bit.

### A Few More Tools

Since we're already talking about the Umputun tool stack, here are three more tools I use.

[revmux](https://github.com/umputun/revmux) - for an agent-driven review loop at the end of the development cycle. Several reviewer agents look at different aspects of the result, then their findings are combined and verified. The implementer fixes the issues, and we run another round.This is a different scope of review from pair programming: there, a single reviewer looks at each step as a whole; here, multiple agents review the full implementation from different angles.

[revdiff](https://github.com/umputun/revdiff) - for my own feedback on plans and code. I open a plan or diff in the terminal and annotate specific lines: fix the comments here, simplify this logic, rewrite this bit. The annotations go back to the agent in a structured format, tied to the relevant location. I don't have to explain in chat which paragraph of the plan or piece of code I mean.

[ralphex](https://github.com/umputun/ralphex) - an implementation of the [Ralph Loop](https://github.com/snarktank/ralph) for executing a long, step-by-step plan with a review at the end. It works through the tasks, runs checks, and commits the results, with each step running in a fresh agent session. I used it quite a lot before, but less and less now with auto-mode in Claude. 

All of these tools come with Claude Code skills, of course, which makes setting them up the way I want much easier.

### Where This Leaves Me

Almost every trick here can work on its own: a coordinator doesn't necessarily need a dashboard, and you can do retros on completed tasks without a coordinator. But they work quite well together for me - I have fewer things to keep track of myself, and less information to copy back and forth.

Strictly speaking, Agterm isn't required either. You could put together a similar setup with tmux and use files as a message bus between agents: one writes a message, another reads it and replies. Agterm just makes it more convenient, more native, and easier to see what's going on.

I haven't completely stopped being a bottleneck, but slightly fewer decisions need to come to me now: I've let the coordinator make small, non-destructive decisions (like rerunning a failed pipeline) on its own. And when it does need me, I spend less time re-reading conversations and trying to remember what we've been doing.

So now I have my own little office in the terminal, with a manager, retros, and pair programming. I just need to make sure I don't start making them sit through meetings that should've been emails :)
