extends Node

signal task_slots_changed

var taskList: Array[String] = []
var taskDetails = {
	"IT": ['Answer IT ticket emails', 'Attend standup meeting', 'Update the new updates article nobody reads', 'Clean up legacy code', 'Review bug tickets', 'Attend to 12 tickets for demons needing assistance restarting their computer', 'Unplug and replug HR department’s printers (27)', 'Review code project merge requests with no comments', 'Complete mandatory internet safety training', 'Write a 10-page report on why the Wi-Fi crashed last week', 'Train an intern to close tabs (there are 187 open)'],
	"Sales": ['Strategy meeting with team', 'Answer emails', 'Review recent contracts', 'Follow up on potential clients', 'Organize new client leads', 'Data entry in silence', 'Reorganize files alphabetically', 'Complete Manipulation training until reaching a perfect score', 'Solo shift at the crossroads', 'Shadow the new hire’s first soul deal', 'Present quarterly projections to an empty conference room for “practice.”'],
	"Demon Resources": ['Review incoming applicants', 'Conduct second stage interviews', 'Deny PTO requests', 'Complete mandatory customer service training', 'Respond to all emails', 'Announce new decaf policy in the break room', 'Hold handling meeting for coworkers causing disruption during work', 'Update 200 outdated policies that no one reads', 'Organize a grief circle for demons demoted to Floor 404', 'Address all complaints from the complaint box by assuming who made the complaints', 'Prepare 100 laminated “Teamwork is Eternal” posters']
}
var traitOptions = {
	"IT": ['Low patience', 'Arrogant', 'Hates ambiguity'],
	"Sales": ['Charismatic', 'People-pleaser', 'Hates to be alone'],
	"Demon Resources": ['Overly formal', 'Rule-oriented', 'Hates conflict and confrontation']
}
var department: String = "IT"
var traitsList: Array[String] = []
var draggingTask: String = ""
var task_slots := [
	
]

func update_task_slot(index: int, task_name: String):
	if index >= 0 and index < task_slots.size():
		task_slots[index]["task"] = task_name
		task_slots_changed.emit()
		print("MiseryManager: Updated slot ", index, " with task: ", task_name)