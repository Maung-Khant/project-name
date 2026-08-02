## How to Submit Your Project Proposal

Follow these steps to submit your Linux System Administration project proposal.

### 1. Fork & Clone the Repository
If you haven't already, fork this repository to your GitHub account and clone it to your local machine:

```bash
git clone [https://github.com/](https://github.com/)<your-github-username>/<repo-name>.git
cd <repo-name>
```

---

### 2. Create a New Branch

Create a branch named after your proposal:

```bash
git checkout -b proposals/<your-github-username>
```

---

### 3. Duplicate the Template

Copy the proposal template file into the `proposals/` directory using your GitHub username as the file name:

```bash
cp project-proposals/_TEMPLATE.md project-proposals/<your-github-username>.md

```

> **Note:** Filename casing must be the same as your github username. (e.g., `WythWin.md` and `wythwin.md` are not the same.).

---

### 4. Fill Out Your Proposal

Open `project-proposals/<your-github-username>.md` in your text editor and complete all required sections:

* [ ] Fill in `{{Project Name}}` and `@{{your-github}}` in the title.
* [ ] Complete **Gist**, **Story**, and **Why**.
* [ ] Define explicit scope boundaries under **Why Not**.
* [ ] Specify OS, services, and stack under **Tech Spec**.
* [ ] Detail your **Security & Backup Plan**.
* [ ] Add clear, testable completion criteria in **Definition of Done**.

---

### 5. Commit and Push

Add your file, commit with a descriptive message, and push to your fork:

```bash
git add project-proposals/<your-github-username>.md
git commit -m "docs: add project proposal for <your-github-username>"
git push origin proposals/<your-github-username>
```

---

### 6. Open a Pull Request (PR)

1. Go to your fork on GitHub .
2. lick **Compare & pull request**.
3. Set the PR title to: `Proposal: <Project Name> (@<your-github-username>)`.
4. Submit the PR for review.

## Proposal Checklist Before Submitting

* [ ] File is located in `project-proposals/<your-github-username>.md`.
* [ ] No empty or default placeholders (`{{...}}`) remain.
* [ ] Scope walls (**Why Not**) are clearly defined.
* [ ] Verification steps in **Definition of Done** are actionable and testable.

---