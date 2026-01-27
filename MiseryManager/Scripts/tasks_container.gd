@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var task_scene: PackedScene
@export var misery_manager: MiseryManager

const TaskDataResource = preload("res://MiseryManager/Scripts/task_data.gd")


const TASK_TEMPLATES = [
	{"title": "Fix the Printer", "description": "Repair the infernal printer that melts every hour.", "tags": ['repetitive', 'humiliating'], "misery_score": 11},
	{"title": "Eternal Ticket Queue", "description": "Clear tech support tickets that regenerate endlessly.", "tags": ['ambiguous', 'repetitive'], "misery_score": 20},
	{"title": "Reset Passwords", "description": "Reset every demon's forgotten login credentials.", "tags": ['repetitive', 'social'], "misery_score": 13},
	{"title": "Debug Mainframe", "description": "Find the source of screaming errors in the infernal mainframe.", "tags": ['ambiguous'], "misery_score": 12},
	{"title": "Reboot Servers", "description": "Manually restart servers scattered across 27 floors.", "tags": ['repetitive', 'physical'], "misery_score": 9},
	{"title": "Update Software", "description": "Run mandatory updates while demons continue working.", "tags": ['tedious', 'repetitive'], "misery_score": 11},
	{"title": "Repair Laptops", "description": "Fix laptops damaged by brimstone spills.", "tags": ['physical', 'tedious'], "misery_score": 4},
	{"title": "Translate Bug Reports", "description": "Interpret vague, unhelpful bug reports.", "tags": ['ambiguous'], "misery_score": 12},
	{"title": "Patch Firewall", "description": "Reinforce the actual wall of fire that protects the network.", "tags": ['physical'], "misery_score": 1},
	{"title": "Clean Data Spill", "description": "Mop up corrupted information puddles.", "tags": ['tedious'], "misery_score": 3},
	{"title": "Install Security Updates", "description": "Apply updates rune-by-rune to every device.", "tags": ['repetitive', 'tedious'], "misery_score": 11},
	{"title": "Kindness Training", "description": "Attend an HR seminar on \"Nonviolent Communication.\"", "tags": ['social', 'humiliating'], "misery_score": 8},
	{"title": "Investigate Downloads", "description": "Track down who pirated mortal souls on the office Wi-Fi.", "tags": ['ambiguous', 'social'], "misery_score": 17},
	{"title": "Glitch Gremlin Issue", "description": "Remove the gremlin chewing through cables.", "tags": ['ambiguous', 'physical'], "misery_score": 13},
	{"title": "System Backup", "description": "Back up the system to cursed floppy disks.", "tags": ['repetitive', 'tedious'], "misery_score": 11},
	{"title": "Cold-Call Angry Customers", "description": "Make calls to furious Hell residents demanding refunds.", "tags": ['conflict', 'rejection'], "misery_score": 20},
	{"title": "Quarterly Report Alone", "description": "Present the sales report without any team support.", "tags": ['embarrassing', 'solo'], "misery_score": 22},
	{"title": "Upsell Useless Product", "description": "Attempt to sell pointless upgrades demons don't need.", "tags": ['rejection', 'embarrassing'], "misery_score": 22},
	{"title": "Handle Complaints", "description": "Resolve customer issues without assistance.", "tags": ['conflict', 'solo'], "misery_score": 20},
	{"title": "Lead Meeting Unprepared", "description": "Run the sales meeting despite not reviewing the notes.", "tags": ['embarrassing', 'high_stakes'], "misery_score": 18},
	{"title": "Reject Refunds", "description": "Deny all refund requests regardless of merit.", "tags": ['conflict', 'rejection'], "misery_score": 20},
	{"title": "Solo Networking Event", "description": "Attend a networking mixer alone.", "tags": ['solo', 'social'], "misery_score": 11},
	{"title": "Host Team-Building", "description": "Lead an activity everyone instantly hates.", "tags": ['embarrassing', 'conflict'], "misery_score": 22},
	{"title": "Fire Demon", "description": "Terminate a demon for poor performance.", "tags": ['conflict'], "misery_score": 10},
	{"title": "Pitch to Execs", "description": "Deliver an improvised pitch to intimidating executives.", "tags": ['high_stakes', 'embarrassing'], "misery_score": 18},
	{"title": "Door-to-Door Surveys", "description": "Survey Hell residents in person.", "tags": ['social'], "misery_score": 1},
	{"title": "Serve VIP Clients", "description": "Handle elite demons who judge everything you do.", "tags": ['high_stakes', 'embarrassing'], "misery_score": 18},
	{"title": "Denial Calls", "description": "Inform clients they did not qualify for service upgrades.", "tags": ['conflict', 'rejection'], "misery_score": 20},
	{"title": "Peer Feedback", "description": "Give honest performance feedback to a coworker.", "tags": ['conflict'], "misery_score": 10},
	{"title": "Run Expo Booth Alone", "description": "Operate a promotional booth without team support.", "tags": ['solo', 'high_stakes'], "misery_score": 16},
	{"title": "Mediate Feud", "description": "Stop two demons fighting over office drama.", "tags": ['conflict'], "misery_score": 12},
	{"title": "Design HR Poster", "description": "Create a cheerful motivational poster from scratch.", "tags": ['creative', 'casual'], "misery_score": 20},
	{"title": "Casual Icebreakers", "description": "Run an informal team bonding session.", "tags": ['casual', 'social', 'creative'], "misery_score": 25},
	{"title": "Handle Complaints About Himself", "description": "Address anonymous criticisms sent to HR.", "tags": ['conflict', 'humiliating'], "misery_score": 15},
	{"title": "Resolve Dept Drama", "description": "Untangle chaos between rival departments.", "tags": ['conflict', 'ambiguous'], "misery_score": 21},
	{"title": "Exit Interviews", "description": "Interview demons quitting due to workplace misery.", "tags": ['conflict', 'social'], "misery_score": 17},
	{"title": "Creativity Workshop", "description": "Lead a workshop on thinking outside the box.", "tags": ['creative', 'collaborative'], "misery_score": 16},
	{"title": "Write Praise Notes", "description": "Compose personalized compliments for coworkers.", "tags": ['creative', 'casual'], "misery_score": 20},
	{"title": "Loosen Culture Meeting", "description": "Advise management on making Hell \"more fun.\"", "tags": ['ambiguous', 'casual', 'creative'], "misery_score": 29},
	{"title": "Role-Play Bonding", "description": "Guide demons through awkward improv games.", "tags": ['creative', 'social', 'casual'], "misery_score": 25},
	{"title": "Complaint Against Him", "description": "Meet with HR about a complaint filed by a coworker.", "tags": ['conflict'], "misery_score": 12},
	{"title": "Brainstorm Session", "description": "Moderate a freeform idea session with no rules.", "tags": ['creative', 'collaborative'], "misery_score": 16},
	{"title": "Instructionless Form", "description": "Process a form missing all required instructions.", "tags": ['ambiguous'], "misery_score": 9},
	{"title": "Office Birthday Party", "description": "Plan a cheerful surprise party.", "tags": ['casual', 'social'], "misery_score": 15},
	{"title": "Peer Review Circle", "description": "Lead a meeting where demons critique one another.", "tags": ['social', 'conflict'], "misery_score": 17}
]


var traits = {
	"Low patience": {
		"despises": ["repetitive", "tedious"],
		"prefers": []
	},
	"Arrogant": {
		"despises": ["humiliating", "embarrassing"],
		"prefers": ["high_stakes", "creative"]
	},
	"Hates ambiguity": {
		"despises": ["ambiguous"],
		"prefers": []
	},
	"Charismatic": {
		"despises": [],
		"prefers": ["social", "casual", "collaborative", "creative"]
	},
	"People-pleaser": {
		"despises": [],
		"prefers": ["social", "casual"]
	},
	"Hates to be alone": {
		"despises": ["solo"],
		"prefers": ["social"]
	},
	"Overly formal": {
		"despises": ["physical"],
		"prefers": []
	},
	"Rule-oriented": {
		"despises": ["ambiguous"],
		"prefers": []
	},
	"Hates conflict and confrontation": {
		"despises": ["conflict", "rejection"],
		"prefers": []
	}
}
var pregenerated_task_data := []

## Called when the container is added to the scene tree.
## Initializes the task list with random tasks from the current department
## and creates the task nodes to display them.
func _ready():
	add_to_group("tasks_container") # Add group for task detection
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return

	_build_pregenerated_task_data()
	var available_tasks := []
	for task_data in pregenerated_task_data:
		available_tasks.append(_duplicate_task_data(task_data))
	available_tasks.shuffle()
	for i in range(min(count, available_tasks.size())):
		misery_manager.taskList.append(available_tasks[i])

	_place_components()
	
	# Listen for employee change to regenerate tasks
	misery_manager.employee_changed.connect(_on_employee_changed)

## Creates and displays all task nodes from the MiseryManager.taskList.
## Each task is assigned to the "tasks_container" group so it knows it belongs
## to the task list (not in a scheduler slot).
func _place_components():
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return
	for task_data in misery_manager.taskList:
		var task_instance = task_scene.instantiate()
		task_instance.set_task_data(task_data)
		if "misery_manager" in task_instance:
			task_instance.misery_manager = misery_manager
		task_instance.add_to_group("tasks_container") # Assign group BEFORE adding to tree
		add_child(task_instance)

func _build_pregenerated_task_data():
	pregenerated_task_data.clear()
	for template in TASK_TEMPLATES:
		pregenerated_task_data.append(_create_task_data_from_template(template))

func _create_task_data_from_template(template: Dictionary):
	var data = TaskDataResource.new()
	data.title = template.get("title", "")
	data.description = template.get("description", "")
	data.department = template.get("department", misery_manager.department)
	data.tags = template.get("tags", [])
	data.misery_score = template.get("misery_score", 0)
	return data

func _duplicate_task_data(data: TaskData):
	return data.duplicate()

func _on_employee_changed(_index: int):
	print("TasksContainer: Regenerating tasks for next employee")
	regenerate_tasks()

func regenerate_tasks():
	# Clear all existing task nodes
	for child in get_children():
		child.queue_free()
	
	# Generate new random tasks
	var available_tasks := []
	for task_data in pregenerated_task_data:
		available_tasks.append(_duplicate_task_data(task_data))
	available_tasks.shuffle()
	for i in range(min(count, available_tasks.size())):
		misery_manager.taskList.append(available_tasks[i])
	
	# Place new task components
	_place_components()
