using System;
using System.Threading.Tasks;
using Godot;

public partial class CSTest : Node2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready() { }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		this.Position += new Vector2(5 * (float)delta, 0);

		this.Rotation += 0.5f * (float)delta;
		this.Rotation -= 0.5f * (float)delta;

	}
}
