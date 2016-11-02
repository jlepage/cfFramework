/**
 * diOneAdapter
 *
 * @author JLepage
 * @date 31/10/16
 **/
interface {

	public void function initIOC(required cffwk.base.conf.Config config);

	public component function getIOC();

	public any function getObject(required string objectName);

	public void function addObject(required any object, string name = '');

	public void function addConstant(required string name, required any value);

}