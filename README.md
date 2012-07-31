knowledgeinscript
=================
Why:
    I am bad at memoring things. I perfer scrripting the knowledge I obtained from time to time.

What: 
    Here are scripts relate to my every day QA work at for IPA project (freeipa.org). They born to be open sourced since this is an open source project.

    ::Script Naming Stratage:: <topic>.<target>.<action>.<type>

    topic: ipa = ipa project related scripts
           rhel= red hat enterprise linux administration scripts
    target: ipa.user = user operations under ipa project
            ipa.server = ipa server operations unde ipa project
            ...
    action: ipa.user.add = add user operation under ipa project
            ipa.group.add = add group operation under ipa project
            ...
    type  : sh = shell script
            pl = perl script 
            ...

    example: 
        ipa.user.add.sh  : shell script that can create new ipa user under ipa project
        ipa.group.add.sh : shell script that create 1 new group, 3 new ipa users and then append these newly created users to the group

    ::Directory ./ipa ::
    IPA (freeipa.org) related commands. It makes ipa work a little easier

    ::Directory ./rhel::
    Red Hat Enterprise Linux related commands. These scripts should apply to most red hat linux or fedora linux based linux
