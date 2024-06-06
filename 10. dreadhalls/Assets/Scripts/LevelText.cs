using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LevelText : MonoBehaviour {
	private Text text;
	private int level;

	// Use this for initialization
	void Start () {
		text = GetComponent<Text>();
		level = Player.level;
	}
	
	// Update is called once per frame
	void Update () {
		level = Player.level;
		text.text = "Level: " + level;
	}
}
