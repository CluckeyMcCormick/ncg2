extends Node

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

class WeightChoice:
    # What's the value of this weighted choice?
    var value
    # What's the weight of this weighted choice?
    var weight
    # What's the accumulated weight of this choice?
    var acc_weight
    
    func _init(in_value, in_weight, in_acc_weight):
        value = in_value
        weight = in_weight
        acc_weight = in_acc_weight
    
    static func sort_by_acc_weight(a, b):
        return a.acc_weight < b.acc_weight

class WeightedRandomBag:
    # The WeightChoice objects
    var weight_choices = []
    # The total weight - sum of all the "weights" found in weight_choices
    var total_weight = 0.0
    
    # Takes in a value and a weight, ensuring these items can be "rolled"
    func add_item(value, weight):
        var wc = WeightChoice.new(value, weight, total_weight + weight)
        weight_choices.append(wc)
        total_weight += weight
    
    func roll_item():
        # What's the weight we rolled, captured in a weight-choice object?
        var roll_weight
        # What's the index of our roll weight in weight_choices?
        var index
        
        # Roll a new weight - multiplying randf by our total weight ensures a
        # value between 0 and total_weight.
        roll_weight = WeightChoice.new(null, 0, randf() * total_weight)
        
        # Find where this weight choice ought to sit
        index = weight_choices.bsearch_custom(
            roll_weight, WeightChoice, "sort_by_acc_weight"
        )
        # Ensure the index is in-bounds
        index = clamp(index, 0, len(weight_choices) - 1)
        
        # Return the value!
        return weight_choices[index].value
    
