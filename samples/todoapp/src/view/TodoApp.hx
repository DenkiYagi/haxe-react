package view;

import react.ReactRef;
import react.React;
import react.ReactComponent;
import react.ReactMacro.jsx;
import js.html.InputElement;
import store.TodoActions;
import store.TodoItem;
import store.TodoStore;

typedef TodoAppState = {
	items:Array<TodoItem>
}

class TodoApp extends ReactComponentOfState<TodoAppState>
{
	var input:ReactRef<InputElement> = React.createRef();
	var todoStore = new TodoStore();

	public function new(props:Dynamic)
	{
		super(props);

		state = { items:todoStore.list };

		todoStore.changed.add(function() {
			setState({ items:todoStore.list });
		});
	}

	override public function render()
	{
		var unchecked = state.items.filter(function(item) return !item.checked).length;

		var listProps = { data:state.items };
		return jsx(
			<div className="app" style={{margin:"10px"}}>
				<form className="header" onSubmit={addItem}>
					<input ref={input} placeholder="Enter new task description" />
					<input type="submit" className="button-add" value="+" />
				</form>
				<hr/>
				<TodoList ref={mountList} {...listProps} className="list" />
				<hr/>
				<div className="footer"><b>{unchecked}</b> task(s) left</div>
			</div>
		);
	}

	function mountList(comp:ReactComponent)
	{
		trace('List mounted ' + comp.props);
	}

	function addItem(e)
	{
		e.preventDefault();
		var text = input.current.value;
		if (text.length > 0)
		{
			TodoActions.addItem.dispatch(text);
			input.current.value = "";
		}
	}
}
