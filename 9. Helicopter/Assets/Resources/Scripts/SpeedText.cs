using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;

public class SpeedText : MonoBehaviour {
	public GameObject spawner;
	private Text text;
	private float speed;

	// Use this for initialization
	void Start () {
		text = GetComponent<Text>();
	}
	
	// Update is called once per frame
	void Update () {
		speed = SkyscraperSpawner.speed;

		text.text = "Speed: " + speed;
	}
}
