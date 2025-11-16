@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var task_scene: PackedScene

var taskList: Array[String] = []
var department: String = "IT"
var taskDetails = {
	"IT": ['Answer IT ticket emails', 'Attend standup meeting', 'Update the new updates article nobody reads', 'Clean up legacy code', 'Review bug tickets', 'Attend to 12 tickets for demons needing assistance restarting their computer', 'Unplug and replug HR department’s printers (27)', 'Review code project merge requests with no comments', 'Complete mandatory internet safety training', 'Write a 10-page report on why the Wi-Fi crashed last week', 'Train an intern to close tabs (there are 187 open)'],
	"Sales": ['Strategy meeting with team', 'Answer emails', 'Review recent contracts', 'Follow up on potential clients', 'Organize new client leads', 'Data entry in silence', 'Reorganize files alphabetically', 'Complete Manipulation training until reaching a perfect score', 'Solo shift at the crossroads', 'Shadow the new hire’s first soul deal', 'Present quarterly projections to an empty conference room for “practice.”'],
	"Demon Resources": ['Review incoming applicants', 'Conduct second stage interviews', 'Deny PTO requests', 'Complete mandatory customer service training', 'Respond to all emails', 'Announce new decaf policy in the break room', 'Hold handling meeting for coworkers causing disruption during work', 'Update 200 outdated policies that no one reads', 'Organize a grief circle for demons demoted to Floor 404', 'Address all complaints from the complaint box by assuming who made the complaints', 'Prepare 100 laminated “Teamwork is Eternal” posters']
}

func _ready():
	var taskTitles = taskDetails[department]
	taskTitles.shuffle()
	for i in range(count):
		var taskTitle = taskTitles[i]
		taskList.append(taskTitle)

	_place_components()


func _place_components():
	for taskTitle in taskList:
		var task_instance = task_scene.instantiate()
		task_instance.set_text(taskTitle)
		add_child(task_instance)
