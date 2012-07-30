Everything is linked to Account models using Padrino's authorization mechanism.


# Workflows


Try to access without logiging in get redirected to the sessions controller. 

Most of the stuff ultmately extends the auntehticate functionaltiy. we neeed callbacks for autheneticate.

For instance a trackable would just be an after callaack on authenticate.

A confirmable woudl simpyl reject authentication unless a user had confirmed.

We should also include my padrino multi-roles hack in the gem.

If we think abut confirmamble etc  are vlaidations. is that how evise does it/ run a vlidati check to see if it's conirmed et. confirmable is probably simply a custom valdiation

Define needed helpers and controllers on models. call revise_for it hits the model and includes the needed helpers and default routes