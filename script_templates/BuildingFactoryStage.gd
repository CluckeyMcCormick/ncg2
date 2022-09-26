
# This script represents two separate substages in the construction of a
# building using our factory technique. The idea is to isolate the these two
# substages down into one script based on subject matter - i.e. one stage for
# lights, one stage for antennae, etc.

# This function gets called first, in the blueprint stage. This one will most
# likely be run from a thread, so you must avoid creating nodes in it. This is
# where the "planning" should take place, and can be algorithmically complex as
# you need - after all, it's threaded. Any values you wish to carry over to the
# construction stage should be placed in the blueprint Dictionary.
#
# This function doesn't necessarily need to be static, but you do need it if
# you're just going to call this script directly without instancing it or
# attaching it to something.
static func make_blueprint(blueprint : Dictionary):
    pass

# This function gets called after make_blueprint, in the construction stage.
# This function wil not be run from a thread; here is where nodes are spawned
# and placed appropriately. However, it's not threaded, so take care and ensure
# the function isn't too complex. The provided building is a TemplateBuilding,
# any modifications should be made to that node. The blueprint dictionary is the
# same one from the make_blueprint function call.
#
# This function doesn't necessarily need to be static, but you do need it if
# you're just going to call this script directly without instancing it or
# attaching it to something.
static func make_construction(building : Spatial, blueprint : Dictionary):
    pass
