export const randomLchColor = () => {
	const h = Math.random() * 360;
	const c = Math.random() * 100;
	const l = Math.random() * 100;

	return lchToRgb({l, c, h});
}

export const lchToRgb = ({l, c, h}) => {
	const a = c * Math.cos(h * Math.PI / 180);
	const b = c * Math.sin(h * Math.PI / 180);

	return labToRgb({l, a, b});
}

const labToRgb = ({l, a, b}) => {
	const y = (l + 16) / 116;
	const x = isNaN(a) ? y : y + a / 500;
	const z = isNaN(b) ? y : y - b / 200;
	
	{
		const r = x * 3.2406 + y * -1.5372 + z * -0.4986;
		const g = x * -0.9689 + y * 1.8758 + z * 0.0415;
		const b = x * 0.0557 + y * -0.2040 + z * 1.0570;
		
		const linearRgb = [r, g, b].map(v => {
			if (v > 0.0031308) {
			return 1.055 * Math.pow(v, 1 / 2.4) - 0.055;
			} else {
			return 12.92 * v;
			}
		});
		
		return `rgb(${linearRgb[0] * 255}, ${linearRgb[1] * 255}, ${linearRgb[2] * 255})`
	}
}
